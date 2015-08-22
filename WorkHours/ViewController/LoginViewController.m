//
//  LoginViewController.m
//  WorkHours
//
//  Created by Admin on 5/12/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "LoginViewController.h"
#import "UIManager.h"
#import "Constant.h"
#import "SVProgressHUD+WorkHours.h"
#import "iToast.h"
#import "AppContext.h"
#import "ServerManager.h"

@interface LoginViewController () <UITextFieldDelegate>{
    UITextField *activeTextField;
    CGFloat init_TopConstraint;
    CGSize g_keyboardSize;
    
    UIManager *uiManager;
    AppContext *appContext;
}

@property (weak, nonatomic) IBOutlet UITextField *txtUserId;
@property (weak, nonatomic) IBOutlet UIView *viewUserId;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *viewBack;

// add for textfield moving
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutTopConstraint;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // add for textfield moving
    init_TopConstraint = self.layoutTopConstraint.constant;
    g_keyboardSize = CGSizeMake(0, 0);
    
    uiManager = [UIManager sharedInstance];
    appContext = [AppContext sharedInstance];
    
    appContext.isLoginSuccess = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tap];
    
	// add for textfield moving
    [self registerForKeyboardNotifications];
    
    [uiManager isVisibleStatusBar:self.navigationController isShow:NO];
        
    [uiManager roundCornersOnView:self.viewUserId onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:kButtonRoundCorner];
    [uiManager applyTextFieldBGColor:self.txtUserId bgcolor:[UIColor whiteColor]];
    [uiManager applyTextFieldInsetLeft:self.txtUserId inset:10];
    
    [uiManager roundCornersOnView:self.viewPassword onTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:kButtonRoundCorner];
    [uiManager applyTextFieldBGColor:self.txtPassword bgcolor:[UIColor whiteColor]];
    [uiManager applyTextFieldInsetLeft:self.txtPassword inset:10];
    
    [uiManager applyDefaultButtonStyle:self.btnLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma button delegate
- (IBAction)onLoginClicked:(id)sender {
    NSString *szUserName, *szPassword;
    
    szUserName = [self.txtUserId text];
    szPassword = [self.txtPassword text];
    //////////////////////////////////////////////////////
    // are username or password empty?
    //
    if (szUserName.length == 0 || szPassword.length == 0) {
        [[iToast makeText:@"Username or Password is empty!"] show];
        return;
    }
    //////////////////////////////////////////////////////
    
    SHOW_PROGRESS(@"Connecting...");
    [[ServerManager sharedManager] loginUser:szUserName pwd:szPassword success:^(NSString *sessionId, NSString *userId, NSString *fullname) {
        HIDE_PROGRESS;
        // save login user data
        [appContext saveSession:sessionId];
        [appContext saveUserID:[userId intValue]];
        [appContext saveUserFullName:fullname];

        [appContext saveUserName:szUserName];
        
        appContext.isLoginSuccess = YES;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"gotoHome" sender:self];
        });
    } failure:^(NSString *failure) {
        HIDE_PROGRESS_WITH_FAILURE(failure);
    }];
}


#pragma mark - tap gesture
- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap {
    [self.view endEditing:YES];
}


// UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    activeTextField = textField;
    [self dynamicContentScroll:FALSE];
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _txtUserId) {
        [_txtPassword becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (void)registerForKeyboardNotifications
{
    // Register for the events
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardDidShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardHide:)
     name:UIKeyboardDidHideNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillChange:)
     name:UIKeyboardWillChangeFrameNotification
     object:nil];

}


- (void)keyboardDidShow:(NSNotification *)noti {
    [self dynamicContentScroll:noti isKeyboardHide:FALSE];
}

- (void)keyboardWillChange:(NSNotification *)noti {
    [self dynamicContentScroll:noti isKeyboardHide:FALSE];
}

- (void)keyboardHide:(NSNotification *)noti {
    [self dynamicContentScroll:noti isKeyboardHide:TRUE];
}

- (void)dynamicContentScroll:(NSNotification *)noti  isKeyboardHide:(BOOL)bHide   {
    
    if (activeTextField) {
        // get keyboard size when keyboard showing
        g_keyboardSize = [ [ [noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    }
    
    [self dynamicContentScroll:bHide];
}

- (void)dynamicContentScroll:(BOOL)bHide   {
    
    if (bHide) {
        // restore contents
        if (self.layoutTopConstraint.constant != init_TopConstraint) {
            self.layoutTopConstraint.constant = init_TopConstraint;
            
            [UIView animateWithDuration:0.2 animations:^() {
                [self.view layoutIfNeeded];
            }];
        }
    } else {
        if (activeTextField) {
            
            CGRect textFieldRect;
            if (activeTextField == _txtUserId) {
                textFieldRect = [_viewUserId frame];
            } else if (activeTextField == _txtPassword) {
                textFieldRect = [_viewPassword frame];
            } else {
                textFieldRect = CGRectMake(0, 0, 0, 0);
            }
            
            CGRect viewRect = [self.view frame];
            
            CGFloat diffY = (viewRect.size.height - g_keyboardSize.height - textFieldRect.size.height - 10) - textFieldRect.origin.y;
            
            if (diffY < 0) {
                self.layoutTopConstraint.constant += diffY;
                
                [UIView animateWithDuration:0.2 animations:^() {
                    [self.view layoutIfNeeded];
                }];
            }
        }
        
    }
}


@end
