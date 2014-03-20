//
//  WDODatabaseManager.h
//  whodo
//
//  Created by David Chiles on 3/20/14.
//  Copyright (c) 2014 davidchiels. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YapDatabase;

@interface WDODatabaseManager : NSObject

@property (nonatomic, strong) YapDatabase *database;

+ (instancetype)sharedInstance;
+ (NSString *)uniqueID;

@end
