#import <UIKit/UIKit.h>

@interface LicenseViewController : UIViewController
@property(nonatomic, copy) void (^onActivated)(void);
@end
