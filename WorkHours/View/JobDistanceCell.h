//
//  JobDistanceCell.h
//  WorkHours
//
//  Created by Admin on 7/18/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JobDistanceCellDelegate <NSObject>

@end


@interface JobDistanceCell : UITableViewCell

@property (nonatomic, weak) id<JobDistanceCellDelegate> delegate;

- (void)initCellData:(int)jobID jobPostUnit:(NSString*)jobPostUnit jobDescription:(NSString*)jobDescription distance:(double)distance;


@end
