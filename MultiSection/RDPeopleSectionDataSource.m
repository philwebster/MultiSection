#import "RDPeopleSectionDataSource.h"
#import "Models.h"

@implementation RDPeopleSectionDataSource

- (instancetype)initWithResults:(RLMResults *)results
{
    if (self = [super initWithResults:results])
    {
        self.cellClass = [UITableViewCell class];
        self.cellReuseIdentifier = @"personCell";
        self.title = @"People";
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    Person *p = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = p.name;
    return cell;
}

@end
