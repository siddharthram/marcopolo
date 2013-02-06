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

#define kJobCellReuseIdentifier @"JobCellReuseIdentifier"


@interface XMHistoryViewController ()

@end


@implementation XMHistoryViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"History", @"History");
        
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
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleDone target:self action:@selector(showSettings)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    UINib *cellNib = [UINib nibWithNibName:@"XMHistoryTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kJobCellReuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobWasSubmitted:) name:XM_NOTIFICATION_JOB_SUBMITTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskUpdateCompleted:) name:XM_NOTIFICATION_TASK_UPDATE_DONE object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
    XMAppDelegate *appDelegate = (XMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showSubmissionViewWithDelegate:self];
}

- (IBAction)showJobDetailForRow:(int)row
{
    XMJobDetailViewController *jobDetailController = [[XMJobDetailViewController alloc] initWithNibName:@"XMJobDetailViewController" bundle:nil];
    XMJob *theJob = [[XMJobList sharedInstance] jobAtIndex:row];
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
    return [[XMJobList sharedInstance] count];
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
    
    XMJob *theJob = [[XMJobList sharedInstance] jobAtIndex:indexPath.row];
    
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
        cell.label1.textColor = [UIColor redColor];
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
