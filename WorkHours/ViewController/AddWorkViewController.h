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

@property (nonatomic) BOOL              isTestMode;             // Test mode,  YES : testing mode
@property (nonatomic) BOOL              isNewEventMode;         // Event mode :  (YES : New Event,  NO : Edit Event)
@property (nonatomic) int              nConnections;    // Personal hospital connections

- (void)createNewEvent:(NSDate*)eventStartTime eventEndTime:(NSDate*)eventEndTime labourTypeID:(int)labourTypeID;
- (void)editSelectEvent:(TimeSheet *)sheet;

@end
