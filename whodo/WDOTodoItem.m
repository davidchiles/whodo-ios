//
//  WDOTodoItem.m
//  whodo
//
//  Created by David Chiles on 3/20/14.
//  Copyright (c) 2014 davidchiels. All rights reserved.
//

#import "WDOTodoItem.h"

@interface WDOTodoItem()

@property (nonatomic, strong) NSString *id;

@end

@implementation WDOTodoItem


- (id)init
{
    if (self = [super init]) {
        self.completed = NO;
    }
    return self;
}

- (NSString *)key
{
    if (!_key) {
        _key = [[NSUUID UUID] UUIDString];
    }
    return _key;
}



#pragma - mark YapDatabase Encoding

- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init])) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.detail = [decoder decodeObjectForKey:@"detail"];
        self.completed = [decoder decodeBoolForKey:@"completed"];
        self.createdDate = [decoder decodeObjectForKey:@"createdDate"];
        self.dueDate = [decoder decodeObjectForKey:@"dueDate"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.key = [decoder decodeObjectForKey:@"key"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.detail forKey:@"detail"];
    [encoder encodeBool:self.completed forKey:@"completed"];
    [encoder encodeObject:self.createdDate forKey:@"createdDate"];
    [encoder encodeObject:self.dueDate forKey:@"dueDate"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.key forKey:@"key"];
}

@end
