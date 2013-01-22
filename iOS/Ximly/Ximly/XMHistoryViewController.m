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
#import "XMJobDetailViewController.h"

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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"History", @"History");
        
#if 0
        self.historyList = [NSMutableArray arrayWithContentsOfFile:[XMHistoryViewController dataFilePath]];
#else
        self.historyList = [@[@{@"imageID" : @"1", @"status" : @"PROCESSING",  @"time" : @"20 mins ago"},
                            @{@"imageID" : @"2", @"status" : @"NEW", @"time" : @"25 mins ago", @"transcription" : @"Blah blah blah blah.  Blah blah blah blah blah.  Blah blah blah blah blah blah blah blah blah blah."},
                            @{@"imageID" : @"3", @"status" : @"NEW", @"time" : @"2 days ago", @"transcription" : @"Gobbledygook gobbledygook gobbledygook gobbledygook.  Blah blah gobbledygook blah blah.  Gobbledygook blah blah gobbledygook blah blah blah blah blah blah."},
                            @{@"imageID" : @"4",@"title" : @"Whiteboard in San Jose", @"time" : @"2 days ago", @"transcription" : @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."}] mutableCopy];

#endif
        
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Register the nib for our custom cell for re-use
    UINib *cellNib = [UINib nibWithNibName:@"XMHistoryTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kJobCellReuseIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSubmit:(id)sender
{
    XMAppDelegate *appDelegate = (XMAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showSubmissionView];
}

- (IBAction)showJobDetailForRow:(int)row
{
    XMJobDetailViewController *jobDetailController = [[XMJobDetailViewController alloc] initWithNibName:@"XMJobDetailViewController" bundle:nil];
    NSDictionary *jobData = [self.historyList objectAtIndex:row];
    jobDetailController.jobData = jobData;
    
    [self.navigationController pushViewController:jobDetailController animated:YES];
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
    
    cell.thumbnailView.image = [UIImage imageNamed:@"intro.png"];
    
    NSString *labelText = [jobData valueForKey:@"status"];
    
    if (labelText) {
        cell.label1.textColor = [UIColor redColor];
        cell.label1.text = labelText;
        
        labelText = [jobData valueForKey:@"title"];
        cell.label2.text = labelText ? labelText : @"Untitled";
        
        labelText = [jobData valueForKey:@"time"];
        cell.label3.text = labelText ? labelText : @"";
    } else {
        cell.label1.textColor = [UIColor darkTextColor];

        labelText = [jobData valueForKey:@"title"];
        cell.label1.text = labelText ? labelText : @"Untitled";
        
        labelText = [jobData valueForKey:@"time"];
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
