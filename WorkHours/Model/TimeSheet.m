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

@synthesize labourID, startTime, endTime, jobID, companyName, labourTypeID, labourDescription;


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
    labourDescription = [NSString stringWithFormat:@"%@", jobNotes];
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
    labourDescription = [NSString stringWithFormat:@"%@", jobNotes];
}

@end

