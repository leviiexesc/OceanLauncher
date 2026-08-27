#import "OceanVersionsViewController.h"
#import "LauncherProfilesViewController.h"
#include <stdlib.h>

@interface OceanVersionsViewController () <UISearchResultsUpdating>
@property(nonatomic) NSArray<NSString *> *installedVersions;
@end

@implementation OceanVersionsViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) self.title = @"Versions";
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:.025 green:.055 blue:.09 alpha:1];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    UISearchController *search = [[UISearchController alloc] initWithSearchResultsController:nil];
    search.searchResultsUpdater = (id<UISearchResultsUpdating>)self;
    self.navigationItem.searchController = search;
    [self reloadInstalledVersions];
}

- (void)reloadInstalledVersions {
    NSString *versionsPath = [NSString stringWithFormat:@"%s/versions", getenv("POJAV_GAME_DIR") ?: ""];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:versionsPath error:nil];
    self.installedVersions = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *item, NSDictionary *_) {
        BOOL directory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:[versionsPath stringByAppendingPathComponent:item] isDirectory:&directory];
        return directory;
    }]];
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *query = searchController.searchBar.text;
    if (query.length == 0) {
        [self reloadInstalledVersions];
        return;
    }
    self.installedVersions = [self.installedVersions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *item, NSDictionary *_) {
        return [item localizedCaseInsensitiveContainsString:query];
    }]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"INSTALL A LOADER" : @"INSTALLED VERSIONS";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 4 : MAX((NSInteger)self.installedVersions.count, 1);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"version"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"version"];
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:.08];
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1 alpha:.55];
    if (indexPath.section == 0) {
        NSArray *loaders = @[@"Vanilla", @"Fabric", @"Forge", @"NeoForge"];
        cell.textLabel.text = loaders[indexPath.row];
        cell.detailTextLabel.text = @"Choose a profile to install or configure";
        cell.imageView.image = [UIImage systemImageNamed:@"arrow.down.circle"];
    } else if (self.installedVersions.count == 0) {
        cell.textLabel.text = @"No installed versions";
        cell.detailTextLabel.text = @"Select a loader above to get started";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.textLabel.text = self.installedVersions[indexPath.row];
        cell.detailTextLabel.text = @"Installed locally";
        cell.imageView.image = [UIImage systemImageNamed:@"checkmark.circle"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[LauncherProfilesViewController new] animated:YES];
    }
}

@end