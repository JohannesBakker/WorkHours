//
//  UIManager.h
//  JobLog
//
//  Created by Admin on 5/12/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIManager : NSObject

+ (instancetype)sharedInstance;

- (void)isVisibleStatusBar:(UINavigationController *)controller isShow:(BOOL)isShow;

- (void)applyDefaultButtonStyle:(UIButton *)button;
- (void)applyDisableButtonStyle:(UIButton *)button;
- (void)applyDisableCustomButtonStyle:(UIButton *)button;
- (void)applySelectedButtonStyle:(UIButton *)button;
- (void)applyUnselectedButtonStyle:(UIButton *)button;

- (void)applyViewBorder:(UIView *)view borderColor:(UIColor *)borderColor borderWidth:(int)borderWidth;

- (void)applyDefaultTextFieldStyle:(UITextField *)textField;
- (void)applyDefaultTextViewStyle:(UITextView *)textView;

- (void)applyTextFieldBGColor:(UITextField *)textField bgcolor:(UIColor *)bgcolor;
- (void)applyTextFieldInsetLeft:(UITextField *)textField inset:(int)inset;
- (void)applyViewRoundRect:(UIView *)view cornerRadius:(int)cornerRadius;
- (void)applyTextFieldBorderColor:(UITextField *)textField borderColor:(UIColor *)borderColor;
- (UIView *)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(int)radius;

@end
