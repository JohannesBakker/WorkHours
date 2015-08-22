//
//  TimeSheet.m
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TimeSheet.h"
#import "NSDate+Utilities.h"

@implementation TimeSheet

@synthesize labourID, startTime, endTime, jobID, companyName, labourTypeID, jobDescription;


- (void)initWithParam:(int)labourId starttime:(NSString*)starttime endtime:(NSString*)endtime jobId:(int)jobId company:(NSString*)company labourTypeId:(int)labourTypeId jobNotes:(NSString*)jobNotes {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    labourID = labourId;
    startTime = [NSDate alloc];
    startTime = [dateFormatter dateFromString:starttime];
    endTime = [NSDate alloc];
    endTime = [dateFormatter dateFromString:endtime];
    jobID = jobId;
    companyName = [NSString stringWithFormat:@"%@", company];
    labourTypeID = labourTypeId;
    jobDescription = [NSString stringWithFormat:@"%@", jobNotes];
}


- (void)initWithParam:(int)labourId startDateTime:(NSDate*)startDateTime endDateTime:(NSDate*)endDateTime jobId:(int)jobId company:(NSString*)company labourTypeId:(int)labourTypeId jobNotes:(NSString*)jobNotes {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    labourID = labourId;
    startTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:startDateTime];
    endTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:endDateTime];
    jobID = jobId;
    companyName = [NSString stringWithFormat:@"%@", company];
    labourTypeID = labourTypeId;
    jobDescription = [NSString stringWithFormat:@"%@", jobNotes];
}

@end



//---------------------------------------
//      TimeSheetPerDay
//---------------------------------------

@implementation TimeSheetPerDay

@synthesize dayDate, arrTimesheets;

- (void)initWithParam:(NSDate *)selDate arrTimeSheets:(NSMutableArray *)arrTimeSheets
{
    dayDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:selDate];
    
    if (arrTimeSheets != nil) {
        arrTimesheets = [[NSMutableArray alloc] initWithArray:arrTimeSheets];
    } else {
        arrTimesheets = [NSMutableArray array];
    }
}


- (TimeSheet*)getTimesheetFromUserPin:(NSDate *)pinCreationDateTime
{
    for (TimeSheet *oneSheet in arrTimesheets) {
        NSDate *start_time = oneSheet.startTime;
        NSDate *end_time = oneSheet.endTime;
        
        if ( ([start_time isEqualToDate:pinCreationDateTime] || [start_time isEarlierThanDate:pinCreationDateTime])
            && ( [end_time isEqualToDate:pinCreationDateTime] || [end_time isLaterThanDate:pinCreationDateTime] ) ) {
            
            return oneSheet;
        }
    }
    
    return nil;
}

- (BOOL)isValidTimesheetAdding:(TimeSheet *)newTimesheet
{
    if (dayDate == nil || newTimesheet == nil || newTimesheet.startTime == nil)
        return NO;
    
    return [dayDate isEqualToDateIgnoringTime:newTimesheet.startTime];
}

- (void)addNewTimesheet:(TimeSheet *)newTimesheet
{
    if (arrTimesheets == nil) {
        arrTimesheets = [NSMutableArray array];
    }
    
    NSDate *end_time = newTimesheet.endTime;
    
    for (int i = ((int)arrTimesheets.count - 1); i >= 0; i--)
    {
        TimeSheet *oneTImesheet = [arrTimesheets objectAtIndex:(NSUInteger)i];
        
        if ([end_time isEarlierThanDate:oneTImesheet.startTime] || [end_time isEqualToDate:oneTImesheet.startTime]) {
            [arrTimesheets insertObject:newTimesheet atIndex:(NSUInteger)i];
            return;
        }
    }
    
    [arrTimesheets addObject:newTimesheet];
    
}

@end