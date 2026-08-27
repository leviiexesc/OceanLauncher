#import <Foundation/Foundation.h>

@interface LicenseManager : NSObject
+ (BOOL)isActivated;
+ (NSString *)planName;
+ (NSString *)expiryText;
+ (void)activateKey:(NSString *)key completion:(void (^)(BOOL success, NSString *message))completion;
+ (void)clearActivation;
@end
