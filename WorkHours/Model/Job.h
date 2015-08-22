//
//  Job.h
//  WorkHours
//
//  Created by Admin on 7/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kJobId_UNASSIGNED         -1

@interface Job : NSObject

@property (nonatomic) int jobID;                                                             // Job ID
@property (nonatomic, retain) NSString *companyName;                      // company name
@property (nonatomic, retain) NSString *notes;                                       // description
@property (nonatomic) double distance;                                                  // distance

- (void)initWithParam:(int)jobId companyname:(NSString *)companyname jobNotes:(NSString *)jobNotes jobDistance:(double)jobDistance ;

@end
