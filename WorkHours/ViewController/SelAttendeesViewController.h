//
//  SelAttendeesViewController.h
//  WorkHours
//
//  Created by Admin on 7/24/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelAttendeesViewController;

@protocol SelAttendeesViewControllerDelegate <NSObject>

@required
- (void)returnChoosedUserId:(NSMutableArray *)selectedAttendees;

@end


@interface SelAttendeesViewController : UIViewController

@property (nonatomic, retain) NSArray *arrAttendees;
@property (nonatomic, retain) NSArray *arrSelectedAttendees;

@property (nonatomic, retain) id<SelAttendeesViewControllerDelegate> delegate;

@end
