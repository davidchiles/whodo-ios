//
//  WDODatabaseManager.m
//  whodo
//
//  Created by David Chiles on 3/20/14.
//  Copyright (c) 2014 davidchiels. All rights reserved.
//

#import "WDODatabaseManager.h"

#import "YapDatabase.h"


@implementation WDODatabaseManager

- (id)init
{
    if(self = [super init]){
        NSString *databaseFilePath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] absoluteString];
        self.database = [[YapDatabase alloc] initWithPath:[databaseFilePath stringByAppendingPathComponent:@"db.sqlite"]];
    }
    return self;
}

+ (NSString *)uniqueID
{
    return [[NSUUID UUID] UUIDString];
}

+ (instancetype)sharedInstance
{
    static WDODatabaseManager *databaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseManager = [[self alloc] init];
    });
    return databaseManager;
}

@end
