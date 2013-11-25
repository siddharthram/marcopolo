//
//  XMHistoryViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMHistoryViewController.h"

#import "XMAppDelegate.h"
#import "XMColor.h"
#import "XMHistoryTableViewCell.h"
#import "XMImageCache.h"
#import "XMJob.h"
#import "XMImageCache.h"
#import "XMJobDetailViewController.h"
#import "XMJobList.h"
#import "XMUtilities.h"
#import "XMXimlyHTTPClient.h"
#import "XMSettingsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Flurry.h"
#import <QuartzCore/QuartzCore.h>

#define kJobCellReuseIdentifier @"JobCellReuseIdentifier"


@interface XMHistoryViewController ()

@end


@implementation XMHistoryViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Home", @"Home");
        [XMJobList sharedInstance];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Register the nib for our custom cell for re-use
    
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableViewController.tableView = self.tableView;
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];

    [refreshControl addTarget:self action:@selector(reloadDataSource:) forControlEvents:UIControlEventValueChanged];

    self.tableViewController.refreshControl = refreshControl;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor]];

    UIImage *myImage = [UIImage imageNamed:@"settings"];
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setImage:myImage forState:UIControlStateNormal];
    myButton.showsTouchWhenHighlighted = YES;
    myButton.frame = CGRectMake(0.0, 3.0, 24, 24);
    [myButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    self.navigationItem.rightBarButtonItem.tintColor = [XMColor greenColor];

    /*
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    } else {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }
     */
    
//    self.navigationItem.titleView = self.listSelector;
    
    UINib *cellNib = [UINib nibWithNibName:@"XMHistoryTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kJobCellReuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobWasSubmitted:) name:XM_NOTIFICATION_JOB_SUBMITTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskUpdateCompleted:) name:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.selectedListSegmentIndex = [userDefaults integerForKey:@"LastHistoryList"];
    [self setCurrentJobListFromSegmentIndex:self.selectedListSegmentIndex];
    
    if ([self tableView:self.tableView numberOfRowsInSection:0] == 0) {
        self.zeroStateLabel.hidden = NO;
    } else {
        self.zeroStateLabel.hidden = YES;
    }
    


    self.tableView.tableHeaderView = self.searchBar;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)setCurrentJobListFromSegmentIndex:(NSInteger)index
{
    NSArray *oldJobList = self.currentJobList;
    
    switch (index) {
        case 0:
            [Flurry logEvent:@"Select all jobs"];
            self.currentJobList = [[XMJobList sharedInstance] jobList];
            break;
        case 1:
            [Flurry logEvent:@"Select pending jobs"];
            self.currentJobList = [[XMJobList sharedInstance] pendingJobs];
            break;
        case 2:
            [Flurry logEvent:@"Select finished jobs"];
            self.currentJobList = [[XMJobList sharedInstance] finishedJobs];
            break;
            
        default:
            break;
    }
    
    if (self.currentJobList != oldJobList) {
        [self.tableView reloadData];
    }
}

- (void)reloadDataSource:(UIRefreshControl *)sender
{
	self.isReloading = YES;
	[[XMXimlyHTTPClient sharedClient] updateTasks];
}

- (void)dataSourceDidFinishReloading
{
    self.isReloading = NO;
    [self.tableViewController.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSubmit:(id)sender
{
    [Flurry logEvent:@"Tap camera button"];
    XMAppDelegate *appDelegate = (XMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showSubmissionViewWithDelegate:self];
}

- (IBAction)showJobDetailForRow:(int)row
{
    [Flurry logEvent:@"Tap on task"];
    XMJobDetailViewController *jobDetailController = [[XMJobDetailViewController alloc] initWithNibName:@"XMJobDetailViewController" bundle:nil];
    XMJob *theJob = [self.currentJobList objectAtIndex:row];
    jobDetailController.job = theJob;
    
    [self.navigationController pushViewController:jobDetailController animated:YES];
}

- (void)jobWasSubmitted:(id)notification
{
    XMJob *theJob = (XMJob *)[notification object];
    if (theJob) {
        [[XMJobList sharedInstance] insertJob:theJob atIndex:0];
        [[XMJobList sharedInstance] writeToDisk];
        [self.tableView reloadData];
    }
}

- (void)taskUpdateCompleted:(id)notification {
    [self dataSourceDidFinishReloading];
    [self.tableView reloadData];
}

- (IBAction)listSelectorValueChanged:(id)sender
{
    self.selectedListSegmentIndex = [self.listSelector selectedSegmentIndex];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.selectedListSegmentIndex forKey:@"LastHistoryList"];
    
    [self setCurrentJobListFromSegmentIndex:self.selectedListSegmentIndex];
}

#pragma mark - XMSubmission delegate methods

- (void)submissionCancelled
{
    // No op
}

- (void)jobSubmitted:(XMJob *)job
{
    // No op
    // We will handle updating the UI for the new job when we get the XM_NOTIFICATION_JOB_SUBMITTED notification
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numRows =[self.currentJobList count];
    if (numRows > 0) {
        self.zeroStateLabel.hidden = YES;
    }
    return numRows;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMHistoryTableViewCell *cell = (XMHistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kJobCellReuseIdentifier];
    
    XMJob *theJob = [self.currentJobList objectAtIndex:indexPath.row];
    
 //   cell.contentView.backgroundColor = [UIColor underPageBackgroundColor];
    
    if (theJob.thumbnail) {
        cell.waitIndicator.hidden = YES;
        cell.thumbnailView.image = theJob.thumbnail;
    } else if ([theJob.imageURL length] > 0) {
        cell.waitIndicator.hidden = NO;
        cell.thumbnailView.image = nil;
        [[XMXimlyHTTPClient sharedClient] fetchImageWithURL:[NSURL URLWithString:theJob.imageURL]
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [XMImageCache saveImage:responseObject forJob:theJob];
                cell.thumbnailView.image = theJob.thumbnail;
                cell.waitIndicator.hidden = YES;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                cell.waitIndicator.hidden = YES;
            }];
    } else {
        cell.waitIndicator.hidden = YES;
        cell.thumbnailView.image = nil;
    }
    
    
    NSString *labelText = theJob.userTranscription;
    
    cell.transcriptionView.text = labelText ? labelText : @"";
    
    labelText = theJob.durationSinceLastAction;
    cell.durationLabel.text = labelText ? labelText : @"";

    cell.statusImageView.image = [theJob statusImage];
    
    return cell;
}

- (IBAction)showSettings
{
    [self.searchBar resignFirstResponder];
    [Flurry logEvent:@"Show settings"];
    XMSettingsViewController *settingsController = [[XMSettingsViewController alloc] initWithNibName:@"XMSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsController animated:YES];
}

#pragma mark - UITableViewDelegate methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 116;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showJobDetailForRow:indexPath.row];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [self showJobDetailForRow:indexPath.row];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.currentJobList = [[XMJobList sharedInstance] listFilteredBy:searchText];
    [self.tableView reloadData];
   /*
    if ([searchText length] == 0) {
        [searchBar performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.01];
    }
    */
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    self.currentJobList = [[XMJobList sharedInstance] listFilteredBy:searchBar.text];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


@end
