//
//  XMHistoryViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMSubmissionViewController.h"

@interface XMHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, XMSubmissionDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *currentJobList;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UITableViewController *tableViewController;
@property (nonatomic, assign) BOOL isReloading;
@property (nonatomic, strong) IBOutlet UISegmentedControl *listSelector;
@property (nonatomic, assign) NSInteger selectedListSegmentIndex;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

- (IBAction)doSubmit:(id)sender;

- (IBAction)listSelectorValueChanged:(id)sender;

@end
