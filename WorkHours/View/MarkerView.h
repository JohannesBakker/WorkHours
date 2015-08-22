//
//  MarkerView.h
//  WorkHours
//
//  Created by Admin on 5/21/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MarkerView;

@protocol MarkerViewDelegate <NSObject>

- (void)didDetailTap;

@end


@interface MarkerView : UIView

@property (nonatomic, retain) id<MarkerViewDelegate> delegate;

- (void)initWithTimeJobMark:(NSString *)start_time endTime:(NSString *)end_time jobTitle:(NSString *)title jobContent:(NSString *)content;
- (void)initWithSimpleJobMark:(NSString *)time jobTitle:(NSString *)title;

@end
