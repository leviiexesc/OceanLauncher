#import "OceanHomeViewController.h"
#import "LauncherPreferencesViewController.h"
#import "LauncherProfilesViewController.h"
#import "LauncherNewsViewController.h"
#import "OceanVersionsViewController.h"
#import "PLProfiles.h"

@interface OceanHomeViewController ()
@property(nonatomic) CAGradientLayer *backgroundLayer;
@end

@implementation OceanHomeViewController

- (instancetype)init {
    self = [super init];
    if (self) self.title = @"Home";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.025 green:0.055 blue:0.09 alpha:1.0];
    self.backgroundLayer = [CAGradientLayer layer];
    self.backgroundLayer.colors = @[
        (id)[UIColor colorWithRed:0.02 green:0.12 blue:0.20 alpha:1].CGColor,
        (id)[UIColor colorWithRed:0.025 green:0.055 blue:0.09 alpha:1].CGColor
    ];
    self.backgroundLayer.startPoint = CGPointMake(0, 0);
    self.backgroundLayer.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:self.backgroundLayer atIndex:0];

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 18;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:stack];

    UILabel *brand = [UILabel new];
    brand.text = @"OCEAN LAUNCHER";
    brand.textColor = [UIColor colorWithRed:0.38 green:0.88 blue:1 alpha:1];
    brand.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    [stack addArrangedSubview:brand];

    UILabel *greeting = [UILabel new];
    greeting.text = @"Ready to enter your world?";
    greeting.textColor = UIColor.whiteColor;
    greeting.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
    greeting.numberOfLines = 0;
    [stack addArrangedSubview:greeting];

    UIView *profileCard = [self cardView];
    UIStackView *profileStack = [[UIStackView alloc] init];
    profileStack.axis = UILayoutConstraintAxisVertical;
    profileStack.spacing = 8;
    profileStack.translatesAutoresizingMaskIntoConstraints = NO;
    [profileCard addSubview:profileStack];
    [NSLayoutConstraint activateConstraints:@[
        [profileStack.topAnchor constraintEqualToAnchor:profileCard.topAnchor constant:20],
        [profileStack.leadingAnchor constraintEqualToAnchor:profileCard.leadingAnchor constant:20],
        [profileStack.trailingAnchor constraintEqualToAnchor:profileCard.trailingAnchor constant:-20],
        [profileStack.bottomAnchor constraintEqualToAnchor:profileCard.bottomAnchor constant:-20]
    ]];
    UILabel *profileTitle = [UILabel new];
    profileTitle.text = @"ACTIVE PROFILE";
    profileTitle.textColor = [UIColor colorWithWhite:1 alpha:.55];
    profileTitle.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    [profileStack addArrangedSubview:profileTitle];
    UILabel *profileName = [UILabel new];
    profileName.text = PLProfiles.current.selectedProfileName ?: @"Default profile";
    profileName.textColor = UIColor.whiteColor;
    profileName.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
    [profileStack addArrangedSubview:profileName];
    UILabel *version = [UILabel new];
    version.text = [NSString stringWithFormat:@"%@  /  %@", [PLProfiles resolveKeyForCurrentProfile:@"lastVersionId"] ?: @"latest-release", [PLProfiles resolveKeyForCurrentProfile:@"renderer"] ?: @"auto"];
    version.textColor = [UIColor colorWithWhite:1 alpha:.65];
    version.font = [UIFont systemFontOfSize:14];
    [profileStack addArrangedSubview:version];
    [stack addArrangedSubview:profileCard];

    UIButton *play = [self actionButton:@"PLAY" symbol:@"play.fill"];
    [play addTarget:self action:@selector(play:) forControlEvents:UIControlEventPrimaryActionTriggered];
    [stack addArrangedSubview:play];

    UIStackView *quickActions = [[UIStackView alloc] init];
    quickActions.axis = UILayoutConstraintAxisHorizontal;
    quickActions.spacing = 10;
    quickActions.distribution = UIStackViewDistributionFillEqually;
    [quickActions addArrangedSubview:[self navigationButton:@"Versions" symbol:@"square.stack.3d.up.fill" action:@selector(showVersions)]];
    [quickActions addArrangedSubview:[self navigationButton:@"Profiles" symbol:@"person.2.fill" action:@selector(showProfiles)]];
    [quickActions addArrangedSubview:[self navigationButton:@"Settings" symbol:@"slider.horizontal.3" action:@selector(showSettings)]];
    [stack addArrangedSubview:quickActions];

    UILabel *updates = [UILabel new];
    updates.text = @"LATEST UPDATES";
    updates.textColor = [UIColor colorWithWhite:1 alpha:.55];
    updates.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    [stack addArrangedSubview:updates];
    UIView *newsCard = [self cardView];
    UILabel *news = [UILabel new];
    news.text = @"Your worlds, Java Edition\nConnected to the existing metadata and download services.";
    news.textColor = [UIColor colorWithWhite:1 alpha:.8];
    news.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    news.numberOfLines = 0;
    news.translatesAutoresizingMaskIntoConstraints = NO;
    [newsCard addSubview:news];
    [NSLayoutConstraint activateConstraints:@[
        [news.topAnchor constraintEqualToAnchor:newsCard.topAnchor constant:18],
        [news.leadingAnchor constraintEqualToAnchor:newsCard.leadingAnchor constant:18],
        [news.trailingAnchor constraintEqualToAnchor:newsCard.trailingAnchor constant:-18],
        [news.bottomAnchor constraintEqualToAnchor:newsCard.bottomAnchor constant:-18]
    ]];
    [stack addArrangedSubview:newsCard];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [stack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:24],
        [stack.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-28],
        [stack.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor constant:-40]
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.backgroundLayer.frame = self.view.bounds;
}

- (UIView *)cardView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:.10];
    view.layer.cornerRadius = 20;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor colorWithWhite:1 alpha:.12].CGColor;
    return view;
}

- (UIButton *)actionButton:(NSString *)title symbol:(NSString *)symbol {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    button.backgroundColor = [UIColor colorWithRed:0.08 green:0.60 blue:0.82 alpha:1];
    button.layer.cornerRadius = 18;
    button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    [button.heightAnchor constraintEqualToConstant:58].active = YES;
    return button;
}

- (UIButton *)navigationButton:(NSString *)title symbol:(NSString *)symbol action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage systemImageNamed:symbol] forState:UIControlStateNormal];
    button.tintColor = [UIColor colorWithRed:.48 green:.88 blue:1 alpha:1];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:.08];
    button.layer.cornerRadius = 14;
    [button addTarget:self action:action forControlEvents:UIControlEventPrimaryActionTriggered];
    [button.heightAnchor constraintEqualToConstant:48].active = YES;
    return button;
}

- (void)play:(UIButton *)sender { [(id)self.navigationController performSelector:@selector(performInstallOrShowDetails:) withObject:sender]; }
- (void)showProfiles { [self.navigationController pushViewController:[LauncherProfilesViewController new] animated:YES]; }
- (void)showSettings { [self.navigationController pushViewController:[LauncherPreferencesViewController new] animated:YES]; }
- (void)showVersions { [self.navigationController pushViewController:[OceanVersionsViewController new] animated:YES]; }

@end