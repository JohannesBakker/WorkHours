//
//  TimeJobCell.h
//  WorkHours
//
//  Created by Admin on 7/7/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeJobCellDelegate <NSObject>

@end




@interface TimeJobCell : UITableViewCell

@property (nonatomic, weak) id<TimeJobCellDelegate> delegate;

- (void)setJobContents:(NSString *)startTime endTime:(NSString *)endTime jobTitle:(NSString *)title jobDescription:(NSString *)description labourColor:(UIColor *)labourColor;

@end
