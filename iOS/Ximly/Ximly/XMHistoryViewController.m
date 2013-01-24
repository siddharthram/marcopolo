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
#import "XMJobDetailViewController.h"
#import "XMUtilities.h"

#define kJobCellReuseIdentifier @"JobCellReuseIdentifier"

static NSString     *_dataFilePath = nil;


@interface XMHistoryViewController ()

@end

@implementation XMHistoryViewController

+ (NSString *)dataFilePath
{
	if (!_dataFilePath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *dataDirectory = [paths objectAtIndex:0];
        if ([dataDirectory length] > 0) {
            _dataFilePath = [NSString stringWithFormat:@"%@/HistoryData", dataDirectory];
        }
	}
	return _dataFilePath;
}

#define kDummyKey @"DummyKey"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"History", @"History");
        
        [self readHistoryListFromDisk];

        if ([self.historyList count] == 0) {
            [XMImageCache saveImage:[UIImage imageNamed:@"intro.png"] withKey:kDummyKey];
            self.historyList = [@[@{@"imageKey" : kDummyKey, @"status" : @"PROCESSING",  @"time" : @"20 mins ago"},
                            @{@"imageKey" : kDummyKey, @"status" : @"NEW", @"time" : @"25 mins ago", @"transcription" : @"Blah blah blah blah.  Blah blah blah blah blah.  Blah blah blah blah blah blah blah blah blah blah."},
                            @{@"imageKey" : kDummyKey, @"status" : @"NEW", @"time" : @"2 days ago", @"transcription" : @"Gobbledygook gobbledygook gobbledygook gobbledygook.  Blah blah gobbledygook blah blah.  Gobbledygook blah blah gobbledygook blah blah blah blah blah blah."},
                            @{@"imageKey" : kDummyKey,@"title" : @"Whiteboard in San Jose", @"time" : @"2 days ago", @"transcription" : @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."}] mutableCopy];
            [self writeHistoryListToDisk];
        }

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
    UINib *cellNib = [UINib nibWithNibName:@"XMHistoryTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kJobCellReuseIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobWasSubmitted:) name:XM_NOTIFICATION_JOB_SUBMITTED object:nil];
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
    NSDictionary *jobData = [self.historyList objectAtIndex:row];
    jobDetailController.jobData = jobData;
    
    [self.navigationController pushViewController:jobDetailController animated:YES];
}

- (void)jobWasSubmitted:(id)notification
{
    NSDictionary *jobData = (NSDictionary *)[notification object];
    if (jobData) {
        [self.historyList insertObject:jobData atIndex:0];
        [self writeHistoryListToDisk];
        [self.tableView reloadData];
    }
}

- (void)readHistoryListFromDisk
{
    self.historyList = [NSMutableArray arrayWithContentsOfFile:[XMHistoryViewController dataFilePath]];
}

- (void)writeHistoryListToDisk
{
    NSString *filePath = [XMHistoryViewController dataFilePath];
    [self.historyList writeToFile:filePath atomically:YES];
    
    [XMUtilities addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
    NSError *error = nil;
    [[NSFileManager defaultManager] setAttributes: @{NSFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication} ofItemAtPath:filePath error:&error];
}

#pragma mark - XMSubmission delegate methods

- (void)submissionCancelled
{
    // No op
}

- (void)submissionCompletedForJob:(NSDictionary *)jobData
{
    // No op
    // We will handle updating the UI for the new job when we get the XM_NOTIFICATION_JOB_SUBMITTED notification
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.historyList count];
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
    
    NSDictionary *jobData = [self.historyList objectAtIndex:indexPath.row];
    
    NSString *imageKey = [jobData valueForKey:@"imageKey"];
    
    UIImage *anImage = nil;
    
    if ([imageKey length] > 0) {
        anImage = [XMImageCache loadImageForKey:imageKey];
    }
    
    if (anImage) {
        cell.thumbnailView.image = anImage;
    } else {
        cell.thumbnailView.image = [UIImage imageNamed:@"Default.png"];
    }
    
    NSString *labelText = [jobData valueForKey:@"status"];
    
    if (labelText) {
        cell.label1.textColor = [UIColor redColor];
        cell.label1.text = labelText;
        
        labelText = [jobData valueForKey:@"title"];
        cell.label2.font = [UIFont boldSystemFontOfSize:13.0];
        cell.label2.text = labelText ? labelText : @"Untitled";
        
        labelText = [jobData valueForKey:@"time"];
        cell.label3.text = labelText ? labelText : @"";
    } else {
        cell.label1.textColor = [UIColor darkTextColor];

        labelText = [jobData valueForKey:@"title"];
        cell.label1.text = labelText ? labelText : @"Untitled";
        
        labelText = [jobData valueForKey:@"time"];
        cell.label2.font = [UIFont systemFontOfSize:10.0];
        cell.label2.text = labelText ? labelText : @"";
        
        cell.label3.text = @"";
    }
    
    return cell;
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
