#import <UIKit/UIKit.h>

@class RDSectionDataSource;

@interface RDMultiSectionDataSource: NSObject<UITableViewDataSource>

@property NSArray<RDSectionDataSource *> *sections;
@property UITableView *tableView;

- (instancetype)initWithSections:(NSArray<RDSectionDataSource *> *)sections tableView:(UITableView *)tableView;

@end
