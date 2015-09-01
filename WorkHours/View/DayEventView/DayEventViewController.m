//
//  DayEventViewController.m
//  WorkHours
//
//  Created by Admin on 7/7/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "DayEventViewController.h"
#import "TimeJobCell.h"
#import "UserContext.h"
#import "LabourType.h"
#import "Constant.h"
#import "UIManager.h"
#import "AddWorkViewController.h"

#define kTimeJobCellHeight          50.0f
#define kSeperateLaborColor       [UIColor brownColor]
#define kSeperateTravelColor      [UIColor blueColor]


@interface DayEventViewController () <UITableViewDelegate, UITableViewDataSource, TimeJobCellDelegate> {
    NSMutableArray *jobArray;
    
    NSMutableArray *arrTimesheets;
}

@end


@implementation DayEventViewController

@synthesize jobDate, hadJobs;
@synthesize timesheetDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrTimesheets = [NSMutableArray array];
    timesheetDate = [[NSDate alloc] init];
    
    jobArray = [NSMutableArray array];
    
    jobDate = [[NSDate alloc] init];
    hadJobs = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithTimesheets:(NSDate *)date TimesheetList:(NSArray *) TimesheetList {
    
    timesheetDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    
    if (TimesheetList == nil || TimesheetList.count == 0)
    {
        hadJobs = NO;
        [arrTimesheets removeAllObjects];
    }
    else
    {
        hadJobs = YES;
        arrTimesheets = [[NSMutableArray alloc] initWithArray:TimesheetList];
    }
    
    [self.tableView reloadData];
}


- (void)initWithJobs:(NSDate *)date JobList:(NSArray *) jobList {
    
    jobDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    
    if (jobList == nil || jobList.count == 0)
    {
        hadJobs = NO;
        [jobArray removeAllObjects];
    }
    else
    {
        hadJobs = YES;
        jobArray = [[NSMutableArray alloc] initWithArray:jobList];
    }
    
    [self.tableView reloadData];
}

- (void)initWithoutJobs:(NSDate *)date {
    [jobArray removeAllObjects];
    
    jobDate = [date copy];
    hadJobs = NO;
    
    [self.tableView reloadData];
}

- (NSString *)getLabourTypeName:(int)labour_type_id
{
    NSString *szName = @"";
    NSMutableArray *arrLabourType = [UserContext sharedInstance].arrLabourType;;

    for (LabourType *oneType in arrLabourType)
    {
        if (oneType.typeID == labour_type_id) {
            szName = oneType.typeName;
            break;
        }
    }
    
    return szName;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (arrTimesheets && arrTimesheets.count > 0)
        return arrTimesheets.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TimeSheet *currSheet = [arrTimesheets objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    TimeJobCell *cell = (TimeJobCell*)[tableView dequeueReusableCellWithIdentifier:@"TimeJobCell"];
    UIColor *labourColor;
    NSString *description;
    
    if (currSheet.labourTypeID == kLabourTypeId_Labour) {
        labourColor = kSeperateLaborColor;
        description = currSheet.labourDescription;
    } else {
        labourColor = kSeperateTravelColor;
        description = [LabourType labourTypeName:currSheet.labourTypeID];
    }
    
    [cell setJobContents:[dateFormatter stringFromDate:currSheet.startTime]
                 endTime:[dateFormatter stringFromDate:currSheet.endTime]
                jobTitle:[NSString stringWithFormat:@"%d - %@", currSheet.jobID, currSheet.companyName]
          jobDescription:description labourColor:labourColor];
    cell.delegate = self;    
    
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = kTimeJobCellHeight;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TimeSheet *sheet = [arrTimesheets objectAtIndex:indexPath.row];
    UserContext *userContext = [UserContext sharedInstance];
    
    if (userContext.mapDelegate) {
        if ([userContext.mapDelegate respondsToSelector:@selector(gotoEditEventWindow:)]) {
            [userContext.mapDelegate gotoEditEventWindow:sheet];
        }
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
