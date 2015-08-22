//
//  Job.m
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "Job.h"

@implementation Job

@synthesize jobID, companyName, notes, distance;

- (void)initWithParam:(int)jobId companyname:(NSString *)companyname jobNotes:(NSString *)jobNotes jobDistance:(double)jobDistance {
    
    jobID = jobId;
    distance = jobDistance;
    companyName = [NSString stringWithFormat:@"%@", companyname];
    notes = [NSString stringWithFormat:@"%@", jobNotes];
}

@end
