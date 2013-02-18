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
    
    self.navigationItem.titleView = self.listSelector;
    
    UINib *cellNib = [UINib nibWithNibName:@"XMHistoryTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kJobCellReuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobWasSubmitted:) name:XM_NOTIFICATION_JOB_SUBMITTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskUpdateCompleted:) name:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.selectedListSegmentIndex = [userDefaults integerForKey:@"LastHistoryList"];
    [self setCurrentJobListFromSegmentIndex:self.selectedListSegmentIndex];
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

    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    XMJob *theJob = [self.currentJobList objectAtIndex:indexPath.row];
    
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
        if ([theJob.status isEqualToString:kJobStatusTranscribedString]) {
            cell.label1.textColor = [UIColor colorWithRed:0.0 green:.75 blue:0.0 alpha:1.0];
        } else {
            cell.label1.textColor = [UIColor redColor];
        }
        cell.label1.font = [UIFont boldSystemFontOfSize:11.0];
        cell.label1.text = labelText;
        
        labelText = theJob.title;
        cell.label2.font = [UIFont boldSystemFontOfSize:13.0];
        cell.label2.text = labelText ? labelText : @"Untitled";
        
        labelText = theJob.durationSinceLastAction;
        cell.label3.text = labelText ? labelText : @"";
    } else {
        cell.label1.textColor = [UIColor darkTextColor];

        labelText = theJob.title;
        cell.label1.font = [UIFont boldSystemFontOfSize:13.0];
        cell.label1.text = labelText ? labelText : @"Untitled";
        
        labelText = theJob.durationSinceLastAction;
        cell.label2.font = [UIFont systemFontOfSize:10.0];
        cell.label2.text = labelText ? labelText : @"";
        
        cell.label3.text = @"";
    }
    
    return cell;
}

- (IBAction)showSettings
{
    [Flurry logEvent:@"Show settings"];
    XMSettingsViewController *settingsController = [[XMSettingsViewController alloc] initWithNibName:@"XMSettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsController animated:YES];
}

#pragma mark - UITableViewDelegate methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showJobDetailForRow:indexPath.row];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self showJobDetailForRow:indexPath.row];
}
@end
