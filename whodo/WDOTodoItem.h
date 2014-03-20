//
//  WDOTodoItem.h
//  whodo
//
//  Created by David Chiles on 3/20/14.
//  Copyright (c) 2014 davidchiels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WDOTodoItem : NSObject

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;

@property (nonatomic, getter = isCompleted) BOOL completed;

@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSDate * dueDate;

@property (nonatomic, strong) CLLocation *location;

@end
