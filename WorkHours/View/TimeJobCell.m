//
//  TimeJobCell.m
//  WorkHours
//
//  Created by Admin on 7/7/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "TimeJobCell.h"

@interface TimeJobCell()

@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@property (weak, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblJobDescription;

@end

@implementation TimeJobCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setJobContents:(NSString *)startTime endTime:(NSString *)endTime jobTitle:(NSString *)title jobDescription:(NSString *)description {
    
    NSString *strStartTime = @"";
    NSString *strEndTime = @"";
    NSString *strTitle = @"";
    NSString *strDesc = @"";
    
    if (startTime)
        strStartTime = startTime;
    
    if (endTime)
        strEndTime = endTime;
    
    if (title)
        strTitle = title;
    
    if (description)
        strDesc = description;
    
    self.lblStartTime.text = strStartTime;
    self.lblEndTime.text = strEndTime;
    self.lblJobTitle.text = strTitle;
    self.lblJobDescription.text = strDesc;
}

@end
