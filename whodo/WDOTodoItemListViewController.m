//
//  WDOTodoItemListViewController.m
//  whodo
//
//  Created by David Chiles on 3/20/14.
//  Copyright (c) 2014 davidchiels. All rights reserved.
//

#import "WDOTodoItemListViewController.h"

#import "WDOAddTodoItemViewController.h"

#import "WDODatabaseManager.h"
#import "WDOTodoItem.h"
#import "YapDatabaseView.h"
#import "YapDatabase.h"

@interface WDOTodoItemListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YapDatabaseConnection *databaseConnection;
@property (nonatomic, strong) YapDatabaseView *databaseView;
@property (nonatomic, strong) YapDatabaseViewMappings *mappings;

@end

@implementation WDOTodoItemListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"WhoDo";
    
    //////// Setup TableView //////////////
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    /////////// Setup Add Button /////////
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    
    /////////// Setup YapDatabaseView /////////
    
    YapDatabaseViewBlockType groupingBlockType;
    YapDatabaseViewGroupingWithObjectBlock groupingBlock;
    
    YapDatabaseViewBlockType sortingBlockType;
    YapDatabaseViewSortingWithObjectBlock sortingBlock;
    
    groupingBlockType = YapDatabaseViewBlockTypeWithObject;
    groupingBlock = ^NSString *(NSString *collection, NSString *key, id object){
        
        if ([collection isEqualToString:NSStringFromClass([WDOTodoItem class])])
        {
            return @"todo";
        }
        
        return nil; // exclude from view
    };
    
    sortingBlockType = YapDatabaseViewBlockTypeWithObject;
    sortingBlock = ^(NSString *group, NSString *collection1, NSString *key1, id obj1,
                     NSString *collection2, NSString *key2, id obj2){
        
        if ([collection1 isEqualToString:NSStringFromClass([WDOTodoItem class])] && [collection2 isEqualToString:NSStringFromClass([WDOTodoItem class])])
        {
            WDOTodoItem *item1 = (WDOTodoItem *)obj1;
            WDOTodoItem *item2 = (WDOTodoItem *)obj2;
            return [item1.createdDate compare:item2.createdDate];
        }
        return NSOrderedSame;
    };
    
    self.databaseView = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock groupingBlockType:groupingBlockType sortingBlock:sortingBlock sortingBlockType:sortingBlockType];
    
    
    [[WDODatabaseManager sharedInstance].database registerExtension:self.databaseView withName:@"todo-list"];
    
    self.databaseConnection = [[WDODatabaseManager sharedInstance].database newConnection];
    [self.databaseConnection beginLongLivedReadTransaction];
    
    self.mappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[@"todo"] view:@"todo-list"];
    
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.mappings updateWithTransaction:transaction];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(databaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:self.databaseConnection.database];
    
}
#pragma - mark Button Methods

- (void)addButtonPressed:(id)sender
{

    UIViewController *addViewController = [[WDOAddTodoItemViewController alloc] init];
    UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    
    [self presentViewController:modalNavigationController animated:YES completion:nil];
    
}

#pragma - mark YapDatabaseNotification

- (void)databaseModified:(NSNotification *)notification
{
    NSArray *notifications = [self.databaseConnection beginLongLivedReadTransaction];
    
    NSArray *sectionChanges = nil;
    NSArray *rowChanges = nil;
    
    [[self.databaseConnection ext:@"todo-list"] getSectionChanges:&sectionChanges
                                                  rowChanges:&rowChanges
                                            forNotifications:notifications
                                                withMappings:self.mappings];
    
    if (![sectionChanges count] && ![rowChanges count])
    {
        // Nothing has changed that affects our tableView
        return;
    }
    
    [self.tableView beginUpdates];
    
    for (YapDatabaseViewSectionChange *sectionChange in sectionChanges)
    {
        switch (sectionChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionChange.index]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    }
    
    for (YapDatabaseViewRowChange *rowChange in rowChanges)
    {
        switch (rowChange.type)
        {
            case YapDatabaseViewChangeDelete :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeInsert :
            {
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeMove :
            {
                [self.tableView deleteRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[ rowChange.newIndexPath ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
            case YapDatabaseViewChangeUpdate :
            {
                [self.tableView reloadRowsAtIndexPaths:@[ rowChange.indexPath ]
                                      withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
    
    [self.tableView endUpdates];
    
}

#pragma - mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.mappings numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mappings  numberOfItemsInSection:section];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YapDatabaseConnection *connection = [[WDODatabaseManager sharedInstance].database newConnection];
        [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            WDOTodoItem *item = [[transaction extension:@"todo-list"] objectAtIndexPath:indexPath withMappings:self.mappings];
            [transaction setObject:nil forKey:item.key inCollection:NSStringFromClass([item class])];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block WDOTodoItem *item = nil;
    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        item = [[transaction extension:@"todo-list"] objectAtIndexPath:indexPath withMappings:self.mappings];
    }];
    
    NSString *const cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = item.name;
    if (item.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YapDatabaseConnection *connection = [[WDODatabaseManager sharedInstance].database newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        WDOTodoItem *item = [[transaction extension:@"todo-list"] objectAtIndexPath:indexPath withMappings:self.mappings];
        item.completed = !item.isCompleted;
        [transaction replaceObject:item forKey:item.key inCollection:NSStringFromClass([item class])];
    }];
}

@end
