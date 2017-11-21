#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@class RDSectionDataSource;

@protocol RDSectionDataSourceDelegate
- (void)sectionDataSource:(RDSectionDataSource *)section didChange:(RLMCollectionChange *)change;
@end

@interface RDSectionDataSource: NSObject<UITableViewDataSource>

@property RLMResults *results;
@property NSString *title;
@property Class cellClass;
@property NSString *cellReuseIdentifier;
@property id<RDSectionDataSourceDelegate> delegate;
@property RLMNotificationToken *changeToken;

- (instancetype)initWithResults:(RLMResults *)results;

@end


