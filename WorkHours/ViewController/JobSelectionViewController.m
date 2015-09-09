//
//  JobSelectionViewController.m
//  WorkHours
//
//  Created by Admin on 7/18/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "JobSelectionViewController.h"
#import "JobNumberCell.h"
#import "JobDistanceCell.h"
#import "ServerManager.h"
#import "Job.h"
#import "UserContext.h"
#import "AppContext.h"
#import "SVProgressHUD+WorkHours.h"
#import "UIManager.h"
#import "Constant.h"

#define kJobCellHeight      70.0f

@interface JobSelectionViewController () <UITableViewDelegate, UITableViewDataSource, JobNumberCellDelegate, JobDistanceCellDelegate> {
    NSMutableArray *arrJobs;
    BOOL isDisplayByNumber;
}


@property (weak, nonatomic) IBOutlet UITableView *viewJobs;
@property (retain, nonatomic) IBOutlet UIView *viewButton;

@property (weak, nonatomic) IBOutlet UIView *viewConnection;
@property (weak, nonatomic) IBOutlet UILabel *lblConnection;


@end

@implementation JobSelectionViewController

@synthesize nConnections;


@synthesize isTestMode;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // change view color with connection color
    self.view.backgroundColor = self.viewConnection.backgroundColor;
    
    // status bar text color change with white color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set Connections
    self.lblConnection.text = [NSString stringWithFormat:@"%d", nConnections];
    
    // arrJobs = [NSMutableArray array];
    arrJobs = [UserContext sharedInstance].arrJobs;
    
    isDisplayByNumber = YES;
    
    // set Buttone view's border
    [[UIManager sharedInstance] applyViewBorder:self.viewButton borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    
    // remove tableviewcell separator line
    self.viewJobs.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    arrJobs = [UserContext sharedInstance].arrJobs;
    
    [self resortJobs];
    [self.viewJobs reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onBackClicked:(id)sender {
    [self dismiss];
}

- (IBAction)onChangedSortType:(id)sender {
    UISegmentedControl *segType = (UISegmentedControl*)sender;
    
    if (segType.selectedSegmentIndex == 0)
        isDisplayByNumber = YES;
    else
        isDisplayByNumber = NO;
    
    [self resortJobs];
    [self.viewJobs reloadData];

}

- (void)resortJobs {
    
    if (arrJobs == nil || arrJobs.count == 0)
        return;
    
    NSString *sortKey;
    
    if (isDisplayByNumber)
        sortKey = @"jobID";
    else
        sortKey = @"distance";
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [arrJobs sortUsingDescriptors:sortDescriptors];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (arrJobs && arrJobs.count > 0)
        return arrJobs.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = kJobCellHeight;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Job *currJob = [arrJobs objectAtIndex:indexPath.row];
    
    if (isDisplayByNumber) {
        JobNumberCell *cell = (JobNumberCell*)[tableView dequeueReusableCellWithIdentifier:@"JobNumberCell"];
        
        [cell initCellData:currJob.jobID jobPostUnit:currJob.companyName jobDescription:currJob.notes distance:currJob.distance];
        cell.delegate = self;
        
        // set cell border
        [[UIManager sharedInstance] applyViewBorder:cell.contentView borderColor:kCellBorderColor borderWidth:kCellBorderWidth];
        
        return cell;
        
    }
    
    JobDistanceCell *cell = (JobDistanceCell*)[tableView dequeueReusableCellWithIdentifier:@"JobDistanceCell"];
    
    [cell initCellData:currJob.jobID jobPostUnit:currJob.companyName jobDescription:currJob.notes distance:currJob.distance];
    cell.delegate = self;
    
    // set cell border
    [[UIManager sharedInstance] applyViewBorder:cell.contentView borderColor:kCellBorderColor borderWidth:kCellBorderWidth];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Job *selJob = [arrJobs objectAtIndex:indexPath.row];
    
    if (self.delegate) {
        [self.delegate didJobSelected:selJob.jobID postUnit:selJob.companyName notes:selJob.notes];
        
        [self dismiss];
    }
}


@end
