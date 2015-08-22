//
//  JobSelectionViewController.h
//  WorkHours
//
//  Created by Admin on 7/18/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JobSelectionViewControllerDelegate <NSObject>

- (void)didJobSelected:(int)selJobId postUnit:(NSString *)postUnit notes:(NSString *)notes;

@end


@interface JobSelectionViewController : UIViewController

@property (nonatomic) BOOL isTestMode;

@property (nonatomic, retain) id<JobSelectionViewControllerDelegate> delegate;

@end
