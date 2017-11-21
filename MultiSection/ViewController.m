#import "ViewController.h"
#import <Realm/Realm.h>
#import "Models.h"
#import "RDMultiSectionDataSource.h"
#import "RDSectionDataSource.h"
#import "RDDogSectionDataSource.h"
#import "RDPeopleSectionDataSource.h"

@interface ViewController ()

@property RLMRealm *realm;
@property UITableView *tableView;
@property RDMultiSectionDataSource *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [UITableView new];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
    [NSLayoutConstraint activateConstraints:@[
                                              [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                              [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                              ]];
    
    self.realm = RLMRealm.defaultRealm;
    
    RLMResults *dogs = [Dog allObjectsInRealm:self.realm];
    RLMResults *people = [Person allObjectsInRealm:self.realm];
    
    RDSectionDataSource *dogSection = [[RDDogSectionDataSource alloc] initWithResults:dogs];
    RDSectionDataSource *peopleSection = [[RDPeopleSectionDataSource alloc] initWithResults:people];
    
    NSArray<RDSectionDataSource *> *sections = @[dogSection, peopleSection];
    self.dataSource = [[RDMultiSectionDataSource alloc] initWithSections:sections tableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Dog" style:UIBarButtonItemStylePlain target:self action:@selector(addDog)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Person" style:UIBarButtonItemStylePlain target:self action:@selector(addPerson)];
}

- (void)addDog
{
    Dog *myDog = [[Dog alloc] init];
    myDog.name = @"Fido";
    myDog.age = 1;
    [self.realm transactionWithBlock:^{
        [self.realm addObject:myDog];
    }];
}

- (void)addPerson
{
    Person *person = [[Person alloc] init];
    person.name = @"Phil";
    [self.realm transactionWithBlock:^{
        [self.realm addObject:person];
    }];
}

@end
