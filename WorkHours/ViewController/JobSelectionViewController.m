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

#define kJobCellHeight      70.0f

@interface JobSelectionViewController () <UITableViewDelegate, UITableViewDataSource, JobNumberCellDelegate, JobDistanceCellDelegate> {
    NSMutableArray *arrJobs;
    BOOL isDisplayByNumber;
}


@property (weak, nonatomic) IBOutlet UITableView *viewJobs;


@end

@implementation JobSelectionViewController



@synthesize isTestMode;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrJobs = [NSMutableArray array];
    isDisplayByNumber = YES;
    
    [self getJobListFromServer];
    
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

- (void)getJobListFromServer {
    
    SHOW_PROGRESS(@"Fetching data...");
    
    
    double lat = [[AppContext sharedInstance] loadUserLocationLat];
    double lon = [[AppContext sharedInstance] loadUserLocationLng];
    
    if (isTestMode) {
        lat = -33.831370;
        lon = 151.200818;
    }
    
    
    
    [ [ServerManager sharedManager] getJobsByLocation:lat lon:lon success:^(NSMutableArray *arrJobList)
     {
         HIDE_PROGRESS;
         arrJobs = [[NSMutableArray alloc] initWithArray:arrJobList];
         
         [self resortJobs];
         [self.viewJobs reloadData];

         
     } failure:^(NSString *failure)
     {
         HIDE_PROGRESS_WITH_FAILURE(failure);         
         
     } ];
    
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
        
        return cell;
        
    }
    
    JobDistanceCell *cell = (JobDistanceCell*)[tableView dequeueReusableCellWithIdentifier:@"JobDistanceCell"];
    
    [cell initCellData:currJob.jobID jobPostUnit:currJob.companyName jobDescription:currJob.notes distance:currJob.distance];
    cell.delegate = self;
    
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
