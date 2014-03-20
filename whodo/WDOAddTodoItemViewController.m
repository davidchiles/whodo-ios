//
//  WDOAddTodoItemViewController.m
//  whodo
//
//  Created by David Chiles on 3/20/14.
//  Copyright (c) 2014 davidchiels. All rights reserved.
//

#import "WDOAddTodoItemViewController.h"

#import "WDOTodoItem.h"
#import "WDODatabaseManager.h"
#import "YapDatabase.h"
#import "YapDatabaseConnection.h"

@interface WDOAddTodoItemViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation WDOAddTodoItemViewController

- (void)viewDidLoad
{
    self.title = @"New Todo";
    
    [super viewDidLoad];
    /////// Setup Save Button ///////////
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    /////// Setup Cancel Button //////////
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    //////// Setup TextView //////////////
    self.textView = [[UITextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.textView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textView]|"
                                                                      options:0 metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_textView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textView(150)]"
                                                                      options:0 metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_textView)]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

#pragma - mark Button Methods

- (void)saveButtonPressed:(id)sender
{
    WDOTodoItem *newTodoItem = [[WDOTodoItem alloc] init];
    newTodoItem.createdDate = [NSDate date];
    newTodoItem.name = self.textView.text;
    
    WDODatabaseManager *databaseManager = [WDODatabaseManager sharedInstance];
    YapDatabaseConnection *databaseConnection = [databaseManager.database newConnection];
    
    [databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:newTodoItem forKey:newTodoItem.key inCollection:NSStringFromClass([newTodoItem class])];
    }];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
