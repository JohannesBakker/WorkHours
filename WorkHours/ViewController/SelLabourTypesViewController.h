//
//  SelLabourTypesViewController.h
//  WorkHours
//
//  Created by Admin on 7/9/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelLabourTypesViewController;

@protocol SelLabourTypesViewControllerDelegate <NSObject>

- (void)didLabourTypeTap:(int)selTypeId;

@end

@interface SelLabourTypesViewController : UIViewController

@property (nonatomic, retain) NSMutableArray *arrTypes;
@property (nonatomic) int selectedTypes;

@property (nonatomic, retain) id<SelLabourTypesViewControllerDelegate> delegate;

@property (nonatomic) int  nConnections;    // Personal hospital connections

@end
