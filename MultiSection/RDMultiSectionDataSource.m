#import "RDMultiSectionDataSource.h"
#import "RDSectionDataSource.h"

@interface RDMultiSectionDataSource () <RDSectionDataSourceDelegate>
@end

@implementation RDMultiSectionDataSource

- (instancetype)initWithSections:(NSArray<RDSectionDataSource *> *)sections tableView:(UITableView *)tableView
{
    if (self = [super init])
    {
        _sections = sections;
        _tableView = tableView;
        [sections enumerateObjectsUsingBlock:^(RDSectionDataSource * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
            section.delegate = self;
            [tableView registerClass:section.cellClass forCellReuseIdentifier:section.cellReuseIdentifier];
        }];
    }
    return self;
}

- (void)sectionDataSource:(RDSectionDataSource *)section didChange:(RLMCollectionChange *)change
{
    NSInteger sectionIndex = [self.sections indexOfObject:section];
    
    NSMutableArray<NSIndexPath *> *additions = [NSMutableArray array];
    [change.insertions enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [additions addObject:[NSIndexPath indexPathForRow:[obj integerValue] inSection:sectionIndex]];
    }];
    NSMutableArray<NSIndexPath *> *deletions = [NSMutableArray array];
    [change.deletions enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [deletions addObject:[NSIndexPath indexPathForRow:[obj integerValue] inSection:sectionIndex]];
    }];
    NSMutableArray<NSIndexPath *> *modifications = [NSMutableArray array];
    [change.modifications enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [modifications addObject:[NSIndexPath indexPathForRow:[obj integerValue] inSection:sectionIndex]];
    }];

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:additions withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView deleteRowsAtIndexPaths:deletions withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadRowsAtIndexPaths:modifications withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.sections[indexPath.section] tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections[section] tableView:tableView titleForHeaderInSection:section];
}

@end
