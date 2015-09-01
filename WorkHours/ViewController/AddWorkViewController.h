//
//  AddWorkViewController.h
//  WorkHours
//
//  Created by Admin on 5/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeSheet.h"

@interface AddWorkViewController : UIViewController

@property (nonatomic) BOOL              isNewEventMode;         // Event mode :  (YES : New Event,  NO : Edit Event)
@property (nonatomic) int               jobId;            // Job ID
@property (nonatomic, retain) NSString  *jobPostUnit;       // Job Posting Unit
@property (nonatomic, retain) NSString  *jobPostNotes;      // Job description

@property (nonatomic) BOOL              isAllDay;               // Enable/Disable All day
@property (nonatomic, retain)NSDate     *startTime;    // Start time
@property (nonatomic, retain) NSDate    *endTime;      // End time
@property (nonatomic) int               labourTypeId;            // labour Type ID
@property (nonatomic, retain) NSString  *note;       // notes

@property (nonatomic) BOOL              isTestMode;             // Test mode,  YES : testing mode


- (void)updateEventWindow:(BOOL)isNewEvent
                 selJobId:(int)selJobId
                 labourId:(int)labourId
           eventStartTime:(NSDate*)eventStartTime
             eventEndTime:(NSDate*)eventEndTime
         initLabourTypeId:(int)initLabourTypeId
                eventNote:(NSString *)eventNote;

- (void)createNewEvent:(NSDate*)eventStartTime eventEndTime:(NSDate*)eventEndTime;

- (void)editSelectEvent:(TimeSheet *)sheet;

@end
