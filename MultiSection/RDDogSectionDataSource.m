#import "RDDogSectionDataSource.h"
#import "Models.h"

@implementation RDDogSectionDataSource

- (instancetype)initWithResults:(RLMResults *)results
{
    if (self = [super initWithResults:results])
    {
        self.cellClass = [UITableViewCell class];
        self.cellReuseIdentifier = @"dogCell";
        self.title = @"Dogs";
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    Dog *d = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = d.name;
    return cell;
}

@end
