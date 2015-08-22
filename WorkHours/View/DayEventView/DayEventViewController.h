//
//  DayEventViewController.h
//  WorkHours
//
//  Created by Admin on 7/7/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DayEventViewController : UITableViewController

@property (nonatomic, retain) NSDate *jobDate;
@property (nonatomic, retain) NSDate *timesheetDate;
@property (nonatomic) BOOL hadJobs;

- (void)initWithJobs:(NSDate *)date JobList:(NSArray *) jobList ;
- (void)initWithoutJobs:(NSDate *)date ;


- (void)initWithTimesheets:(NSDate *)date TimesheetList:(NSArray *) TimesheetList ;


@end
