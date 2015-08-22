//
//  JobDistanceCell.m
//  WorkHours
//
//  Created by Admin on 7/18/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "JobDistanceCell.h"

@interface JobDistanceCell()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescrtipion;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;


@end

@implementation JobDistanceCell

@synthesize lblTitle, lblDescrtipion, lblDistance;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCellData:(int)jobID jobPostUnit:(NSString*)jobPostUnit jobDescription:(NSString*)jobDescription distance:(double)distance {
    
    NSString *szPostUnit = @"";
    NSString *szDescription = @"";
    
    if (jobPostUnit)
        szPostUnit = jobPostUnit;
    
    if (jobDescription)
        szDescription = jobDescription;
    
    lblTitle.text = [NSString stringWithFormat:@"%d - %@", jobID, szPostUnit];
    lblDescrtipion.text = szDescription;
    lblDistance.text = [NSString stringWithFormat:@"%.02fkm", distance];
}



@end
