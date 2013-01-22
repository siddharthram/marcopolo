//
//  XMHistoryViewController.h
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *historyList;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)doSubmit:(id)sender;

@end
