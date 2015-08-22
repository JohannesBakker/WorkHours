//
//  MarkerView.m
//  WorkHours
//
//  Created by Admin on 5/21/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "MarkerView.h"
#import "UIManager.h"

@interface MarkerView ()

@property (weak, nonatomic) IBOutlet UIImageView *ivTime;
@property (weak, nonatomic) IBOutlet UIImageView *ivBack;

@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

@property (weak, nonatomic) IBOutlet UILabel *lblSimpleTime;
@property (weak, nonatomic) IBOutlet UILabel *lblSimpleTitle;

@property (weak, nonatomic) IBOutlet UIView *timeJobMark;
@property (weak, nonatomic) IBOutlet UIView *simpleJobMark;

@property (nonatomic) BOOL isTimeMark;


@end

@implementation MarkerView

- (id)init {
    self = [super init];
    if (self) {        
        self = [[[NSBundle mainBundle] loadNibNamed:@"MarkerView" owner:self options:nil] lastObject];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 70);
        
        self.isTimeMark = YES;
        [self displayMark:self.isTimeMark];
        
        [[UIManager sharedInstance] applyViewRoundRect:self.ivBack cornerRadius:5];
        [[UIManager sharedInstance] roundCornersOnView:self.ivTime onTopLeft:YES topRight:NO bottomLeft:YES bottomRight:NO radius:5];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)onDetailClicked:(id)sender {
    if (self.delegate != nil) {
        [self.delegate didDetailTap];
    }
}

- (void)displayMark:(BOOL)isShowTimeMark {
    
    if (isShowTimeMark) {
        self.timeJobMark.hidden = NO;
        self.simpleJobMark.hidden = YES;
    } else {
        self.timeJobMark.hidden = YES;
        self.simpleJobMark.hidden = NO;
    }
    
}

- (void)initWithTimeJobMark:(NSString *)start_time endTime:(NSString *)end_time jobTitle:(NSString *)title jobContent:(NSString *)content {
    self.lblStartTime.text = start_time;
    self.lblEndTime.text = end_time;
    self.lblTitle.text = title;
    self.lblContent.text = content;
    
    self.isTimeMark = YES;
    
    [self displayMark:self.isTimeMark];
}

- (void)initWithSimpleJobMark:(NSString *)time jobTitle:(NSString *)title {
    self.lblSimpleTime.text = time;
    self.lblSimpleTitle.text = title;
    
    self.isTimeMark = NO;
    
    [self displayMark:self.isTimeMark];
}

@end
