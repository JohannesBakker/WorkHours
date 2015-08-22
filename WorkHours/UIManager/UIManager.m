//
//  UIManager.m
//  JobLog
//
//  Created by Admin on 5/12/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "UIManager.h"
#import "Constant.h"

@implementation UIManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (void)isVisibleStatusBar:(UINavigationController *)navigationController isShow:(BOOL)isShow {
    [navigationController setNavigationBarHidden:!isShow];
}

- (void)applyDefaultButtonStyle:(UIButton *)button {
    [button setBackgroundColor:kButtonEnableBGColor];
    button.layer.cornerRadius = kButtonRoundCorner;
    
    return;
}

- (void)applyDisableButtonStyle:(UIButton *)button {
    [button setBackgroundColor:kButtonDisableBGColor];
    button.layer.cornerRadius = kButtonRoundCorner;
    
    return;
}

- (void)applyDisableCustomButtonStyle:(UIButton *)button {
    [button setTitleColor:kButtonDisableTitleColor forState:UIControlStateDisabled];
    button.layer.cornerRadius = kButtonRoundCorner;
}

- (void)applySelectedButtonStyle:(UIButton *)button {
    button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    button.layer.borderWidth = (CGFloat)1.0f;
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:(CGFloat)20.0f]];
}

- (void)applyUnselectedButtonStyle:(UIButton *)button {
    button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    button.layer.borderWidth = (CGFloat)1.0f;
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:(CGFloat)20.0f]];
}

- (void)applyViewBorder:(UIView *)view borderColor:(UIColor *)borderColor borderWidth:(int)borderWidth {
    view.layer.borderColor = [borderColor CGColor];
    view.layer.borderWidth = (CGFloat)borderWidth;
}

- (void)applyDefaultTextFieldStyle:(UITextField *)textField {
    [self applyTextFieldInsetLeft:textField inset:20];
    [self applyTextFieldBorderColor:textField borderColor:[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.1f]];
    textField.layer.borderWidth = (CGFloat)1.0f;
    [textField setFont:[UIFont fontWithName:@"Helvetica" size:(CGFloat)24.0f]];
}

- (void)applyDefaultTextViewStyle:(UITextView *)textView {
    textView.layer.borderColor = [[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.1f] CGColor];
    textView.layer.borderWidth = (CGFloat)1.0f;
    [textView setFont:[UIFont fontWithName:@"Helvetica" size:(CGFloat)24.0f]];
}

- (void)applyTextFieldBGColor:(UITextField *)textField bgcolor:(UIColor *)bgcolor {
    textField.backgroundColor = bgcolor;
    
    return;
}

- (void)applyTextFieldInsetLeft:(UITextField *)textField inset:(int)inset {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, inset, textField.layer.bounds.size.height)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    return;
}

- (void)applyTextFieldBorderColor:(UITextField *)textField borderColor:(UIColor *)borderColor {
    textField.layer.borderColor = [borderColor CGColor];
    
    return;
}

- (void)applyViewRoundRect:(UIView *)view cornerRadius:(int)cornerRadius {
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

- (UIView *)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(int)radius {
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0;
        
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        
        return roundedView;
    } else {
        return view;
    }
    
}

@end
