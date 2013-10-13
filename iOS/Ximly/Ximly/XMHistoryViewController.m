//
//  XMHistoryViewController.m
//  Ximly
//
//  Created by Young-Kyu Yoo on 1/21/13.
//  Copyright (c) 2013 Young-Kyu Yoo. All rights reserved.
//

#import "XMHistoryViewController.h"

#import "XMAppDelegate.h"
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
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"073-Setting"] style:UIBarButtonItemStyleDone target:self action:@selector(showSettings)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
//    self.navigationItem.titleView = self.listSelector;
    
    UINib *cellNib = [UINib nibWithNibName:@"XMHistoryTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kJobCellReuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobWasSubmitted:) name:XM_NOTIFICATION_JOB_SUBMITTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskUpdateCompleted:) name:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.selectedListSegmentIndex = [userDefaults integerForKey:@"LastHistoryList"];
    [self setCurrentJobListFromSegmentIndex:self.selectedListSegmentIndex];
    
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
    return [self.currentJobList count];
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
    
    NSString *labelText = theJob.status;
    
    if (labelText) {
 //       cell.label1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
        
        CGSize textSize = [labelText sizeWithFont:cell.label1.font];
        CGRect label1Frame = cell.label1.frame;
        label1Frame.size = CGSizeMake(textSize.width+7.0, textSize.height+2.0);
        cell.label1.frame = label1Frame;
        if ([theJob.status isEqualToString:kJobStatusOpenString]) {
            cell.label1.backgroundColor = [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1.0];
        } else {
            cell.label1.backgroundColor = [UIColor colorWithRed:0.0 green:.5 blue:0.0 alpha:1.0];

        }
        cell.label1.text = labelText;

        CALayer *boxLayer = cell.label1.layer;
        boxLayer.cornerRadius = 2.0;
        boxLayer.masksToBounds = YES;
        // boxLayer.borderWidth = 0;
        // boxLayer.borderColor = [[UIColor darkGrayColor] CGColor];
        // boxLayer.shouldRasterize = YES;
        
        labelText = theJob.userTranscription;
    //    cell.label2.textColor = [UIColor colorWithRed:0.2 green:.2 blue:0.2 alpha:1.0];
//        cell.label2.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
        cell.label2.text = labelText ? labelText : @"";
        
        labelText = theJob.durationSinceLastAction;
   //     cell.label3.textColor = [UIColor colorWithRed:0.2 green:.2 blue:0.2 alpha:1.0];
        cell.label3.text = labelText ? labelText : @"";
    } else {
        cell.label1.textColor = [UIColor darkTextColor];

        labelText = theJob.title;
        cell.label1.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
        cell.label1.text = labelText ? labelText : @"Untitled";
        
        labelText = theJob.durationSinceLastAction;
        cell.label2.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
        cell.label2.text = labelText ? labelText : @"";
        
        cell.label3.text = @"";
    }
    
    NSString *ratingStr = theJob.rating;
    if ([ratingStr length] > 0) {
        if ([ratingStr isEqualToString:kJobRatingGood]) {
           cell.ratingImageView.image = [UIImage imageNamed:@"up_gray"];
       //  cell.ratingImageView.image = [UIImage imageNamed:@"017-ThumbsUp"];
        } else {
            cell.ratingImageView.image = [UIImage imageNamed:@"down_gray"];
         //  cell.ratingImageView.image = [UIImage imageNamed:@"018-ThumbsDown"];
        }
    } else {
        cell.ratingImageView.image = nil;
    }
    
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
