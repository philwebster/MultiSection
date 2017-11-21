#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@class Person;

@interface Dog : RLMObject
@property NSString *name;
@property Person   *owner;
@property NSInteger age;
@end
RLM_ARRAY_TYPE(Dog)

@interface Person : RLMObject
@property NSString             *name;
@property NSDate               *birthdate;
@property RLMArray<Dog *><Dog> *dogs;
@end
RLM_ARRAY_TYPE(Person)

