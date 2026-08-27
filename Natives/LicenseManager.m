#import "LicenseManager.h"
#import "LauncherPreferences.h"
#import <UIKit/UIKit.h>
#import <Security/Security.h>

static NSString * const OceanLicenseKeychainService = @"com.oceanlauncher.license";
static NSString * const OceanLicenseKeychainAccount = @"activation-key";

@implementation LicenseManager

+ (NSString *)storedKey {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: OceanLicenseKeychainService,
        (__bridge id)kSecAttrAccount: OceanLicenseKeychainAccount,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess || result == NULL) return nil;
    NSData *data = CFBridgingRelease(result);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (BOOL)isActivated {
    return [self storedKey].length > 0 && [getPrefObject(@"license.activationId") length] > 0;
}

+ (NSString *)planName {
    return getPrefObject(@"license.plan") ?: @"Unactivated";
}

+ (NSString *)expiryText {
    NSString *expiry = getPrefObject(@"license.expiresAt");
    return expiry.length > 0 ? expiry : @"Lifetime";
}

+ (void)activateKey:(NSString *)key completion:(void (^)(BOOL, NSString *))completion {
    NSString *cleanKey = [[key ?: @"" stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] uppercaseString];
    NSString *endpointString = [NSBundle.mainBundle objectForInfoDictionaryKey:@"OceanLicenseAPIURL"];
    NSURL *endpoint = [NSURL URLWithString:endpointString ?: @""];
    if (cleanKey.length < 8 || endpoint == nil || endpoint.scheme.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, @"Enter a valid key and configure the reseller license server."); });
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:endpoint];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *payload = @{
        @"key": cleanKey,
        @"deviceId": UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"unknown",
        @"appVersion": [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"unknown"
    };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *message = @"License activation failed.";
        if (error != nil) {
            message = @"Could not reach the license server. Check your internet connection.";
        } else if (![response isKindOfClass:NSHTTPURLResponse.class] || ((NSHTTPURLResponse *)response).statusCode < 200 || ((NSHTTPURLResponse *)response).statusCode >= 300) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            message = [result[@"message"] isKindOfClass:NSString.class] ? result[@"message"] : @"The license server rejected this key.";
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([result[@"valid"] boolValue] && [result[@"licenseId"] isKindOfClass:NSString.class]) {
                NSData *keyData = [cleanKey dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *query = @{
                    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                    (__bridge id)kSecAttrService: OceanLicenseKeychainService,
                    (__bridge id)kSecAttrAccount: OceanLicenseKeychainAccount
                };
                NSMutableDictionary *item = query.mutableCopy;
                item[(__bridge id)kSecValueData] = keyData;
                item[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
                SecItemDelete((__bridge CFDictionaryRef)query);
                SecItemAdd((__bridge CFDictionaryRef)item, NULL);
                setPrefObject(@"license.activationId", result[@"licenseId"]);
                setPrefObject(@"license.plan", [result[@"plan"] isKindOfClass:NSString.class] ? result[@"plan"] : @"Lifetime");
                setPrefObject(@"license.expiresAt", [result[@"expiresAt"] isKindOfClass:NSString.class] ? result[@"expiresAt"] : @"");
                dispatch_async(dispatch_get_main_queue(), ^{ completion(YES, @"License activated successfully."); });
                return;
            }
            message = [result[@"message"] isKindOfClass:NSString.class] ? result[@"message"] : message;
        }
        dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, message); });
    }] resume];
}

+ (void)clearActivation {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: OceanLicenseKeychainService,
        (__bridge id)kSecAttrAccount: OceanLicenseKeychainAccount
    };
    SecItemDelete((__bridge CFDictionaryRef)query);
    setPrefObject(@"license.activationId", nil);
    setPrefObject(@"license.plan", nil);
    setPrefObject(@"license.expiresAt", nil);
}

@end
