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

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic) BOOL initLabourTypeId;

@property (nonatomic) BOOL isTestMode;

@end
