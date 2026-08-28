#import "LauncherNewsViewController.h"
#import "utils.h"

@interface LauncherNewsViewController ()
@end

@implementation LauncherNewsViewController

- (id)init {
    self = [super init];
    self.title = localize(@"News", nil);
    return self;
}

- (NSString *)imageName {
    return @"MenuNews";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.025 green:0.055 blue:0.09 alpha:1.0];
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;

    CAGradientLayer *background = [CAGradientLayer layer];
    background.colors = @[(id)[UIColor colorWithRed:0.02 green:0.12 blue:0.20 alpha:1].CGColor,
                          (id)[UIColor colorWithRed:0.16 green:0.55 blue:0.78 alpha:1].CGColor];
    background.startPoint = CGPointMake(0.5, 0);
    background.endPoint = CGPointMake(0.5, 1);
    background.frame = self.view.bounds;
    [self.view.layer insertSublayer:background atIndex:0];

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stack];

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppLogo-Vector"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [logo.heightAnchor constraintEqualToConstant:130].active = YES;
    [stack addArrangedSubview:logo];

    UILabel *welcome = [self label:localize(@"news.welcome", nil) size:22 weight:UIFontWeightBold];
    welcome.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:welcome];

    UIStackView *links = [[UIStackView alloc] init];
    links.axis = UILayoutConstraintAxisHorizontal;
    links.spacing = 12;
    links.distribution = UIStackViewDistributionFillEqually;
    [links addArrangedSubview:[self pill:localize(@"news.discord", nil)]];
    [links addArrangedSubview:[self pill:localize(@"news.downloads", nil)]];
    [stack addArrangedSubview:links];

    UIView *socialPanel = [UIView new];
    socialPanel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.10];
    socialPanel.layer.cornerRadius = 16;
    UIStackView *socials = [[UIStackView alloc] init];
    socials.axis = UILayoutConstraintAxisHorizontal;
    socials.distribution = UIStackViewDistributionFillEqually;
    socials.translatesAutoresizingMaskIntoConstraints = NO;
    [socialPanel addSubview:socials];
    [NSLayoutConstraint activateConstraints:@[
        [socials.topAnchor constraintEqualToAnchor:socialPanel.topAnchor constant:16],
        [socials.leadingAnchor constraintEqualToAnchor:socialPanel.leadingAnchor constant:8],
        [socials.trailingAnchor constraintEqualToAnchor:socialPanel.trailingAnchor constant:-8],
        [socials.bottomAnchor constraintEqualToAnchor:socialPanel.bottomAnchor constant:-16]
    ]];
    [socials addArrangedSubview:[self label:localize(@"news.youtube", nil) size:14 weight:UIFontWeightRegular]];
    [socials addArrangedSubview:[self label:localize(@"news.facebook", nil) size:14 weight:UIFontWeightRegular]];
    [socials addArrangedSubview:[self label:localize(@"news.tiktok", nil) size:14 weight:UIFontWeightRegular]];
    for (UILabel *label in socials.arrangedSubviews) label.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:socialPanel];

    UILabel *credit = [self label:localize(@"news.developed_by", nil) size:14 weight:UIFontWeightRegular];
    credit.textAlignment = NSTextAlignmentCenter;
    [stack addArrangedSubview:credit];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [stack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:28],
        [stack.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-24],
        [stack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-28],
        [stack.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-48]
    ]];
}

- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight {
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)pill:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    button.backgroundColor = [UIColor colorWithRed:0.04 green:0.62 blue:0.86 alpha:1];
    button.layer.cornerRadius = 16;
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [button.heightAnchor constraintEqualToConstant:42].active = YES;
    return button;
}

@end