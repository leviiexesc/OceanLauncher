#import "LicenseViewController.h"
#import "LicenseManager.h"

@interface LicenseViewController ()
@property(nonatomic) UITextField *keyField;
@property(nonatomic) UIButton *activateButton;
@property(nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation LicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:.025 green:.055 blue:.09 alpha:1];

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.alignment = UIStackViewAlignmentFill;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stack];

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppLogo"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [logo.heightAnchor constraintEqualToConstant:96].active = YES;
    [stack addArrangedSubview:logo];

    UILabel *title = [UILabel new];
    title.text = @"Activate Ocean Launcher";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    title.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:title];

    UILabel *subtitle = [UILabel new];
    subtitle.text = @"Enter the license key supplied by your reseller to continue.";
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:.68];
    subtitle.font = [UIFont systemFontOfSize:15];
    subtitle.numberOfLines = 0;
    subtitle.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:subtitle];

    self.keyField = [UITextField new];
    self.keyField.placeholder = @"XXXX-XXXX-XXXX-XXXX";
    self.keyField.textColor = UIColor.whiteColor;
    self.keyField.tintColor = [UIColor colorWithRed:.38 green:.88 blue:1 alpha:1];
    self.keyField.backgroundColor = [UIColor colorWithWhite:1 alpha:.10];
    self.keyField.layer.cornerRadius = 12;
    self.keyField.layer.borderWidth = 1;
    self.keyField.layer.borderColor = [UIColor colorWithWhite:1 alpha:.14].CGColor;
    self.keyField.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.keyField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.keyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.keyField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 1)];
    self.keyField.leftViewMode = UITextFieldViewModeAlways;
    [self.keyField.heightAnchor constraintEqualToConstant:52].active = YES;
    [stack addArrangedSubview:self.keyField];

    self.activateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.activateButton setTitle:@"Activate license" forState:UIControlStateNormal];
    [self.activateButton setImage:[UIImage systemImageNamed:@"checkmark.seal.fill"] forState:UIControlStateNormal];
    self.activateButton.tintColor = UIColor.whiteColor;
    self.activateButton.backgroundColor = [UIColor colorWithRed:.08 green:.60 blue:.82 alpha:1];
    self.activateButton.layer.cornerRadius = 14;
    self.activateButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.activateButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
    [self.activateButton addTarget:self action:@selector(activate) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.activateButton.heightAnchor constraintEqualToConstant:52].active = YES;
    [stack addArrangedSubview:self.activateButton];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.color = UIColor.whiteColor;
    self.spinner.hidesWhenStopped = YES;
    [stack addArrangedSubview:self.spinner];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [stack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:56],
        [stack.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:28],
        [stack.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-28],
        [stack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:40],
        [stack.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-56]
    ]];
}

- (void)activate {
    self.activateButton.enabled = NO;
    [self.spinner startAnimating];
    [LicenseManager activateKey:self.keyField.text completion:^(BOOL success, NSString *message) {
        self.activateButton.enabled = YES;
        [self.spinner stopAnimating];
        if (!success) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Activation failed" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        if (self.onActivated) self.onActivated();
    }];
}

@end
