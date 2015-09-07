//
//  AddWorkViewController.m
//  WorkHours
//
//  Created by Admin on 5/20/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AddWorkViewController.h"
#import "UIManager.h"
#import "Constant.h"
#import "NSDate+timeZone.h"
#import "ServerManager.h"
#import "iToast.h"
#import "SVProgressHUD+WorkHours.h"
#import <UIKit/UIKit.h>
#import "SelLabourTypesViewController.h"
#import "UserContext.h"
#import "AppContext.h"
#import "JobSelectionViewController.h"
#import "UserInfo.h"
#import "LabourType.h"
#import "NSDate+Utilities.h"
#import "Job.h"
#import "SelAttendeesViewController.h"

#define kDatePickerHeight       162.0f

#define kAnimationDuration      2.0f

#define kMultiPickerViewWidth [UIScreen mainScreen].bounds.size.width
#define kMultiPickerViewHeight 260.0f

@interface AddWorkViewController () <UITextFieldDelegate, UIScrollViewDelegate, SelLabourTypesViewControllerDelegate, JobSelectionViewControllerDelegate, SelAttendeesViewControllerDelegate, NewEventWindowDelegate> {
    BOOL isCollapsedStartDate;
    BOOL isCollapsedEndDate;
    BOOL isCollapsedType;
    BOOL isCollapsedAttendees;
    
    BOOL isShowedAttendeeList;
    
    BOOL isAllDay;
    
    int selectedLabourTypes;
    
    CGFloat fInit_constraitTopOfAttendee;
    CGFloat fInit_constraitTopOfNote;
    
    UITextField *activeTextField;
    CGFloat init_TopConstraint;
    CGSize g_keyboardSize;
    
    int selectedJobId;
    NSString *selectedJobPostUnit;
    NSString *selectedJobNote;
    
    NSMutableArray *typeArray;
    
    NSMutableArray *attendeeArray;
    NSMutableArray *attendeeSeletedArray;
    NSMutableDictionary *attendeeSelectionStates;
}

@property (retain, nonatomic) IBOutlet UIView *viewJob;
@property (retain, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblJobDescription;
@property (retain, nonatomic) IBOutlet UIButton *btnJob;

@property (retain, nonatomic) IBOutlet UISwitch *switchAllDay;

@property (retain, nonatomic) IBOutlet UIView *viewStartDate;
@property (retain, nonatomic) IBOutlet UIButton *btnStart;
@property (retain, nonatomic) IBOutlet UIDatePicker *dtPickerStart;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *constraitTopOfEndDate;
@property (retain, nonatomic) IBOutlet UIButton *btnEnd;
@property (retain, nonatomic) IBOutlet UIView *viewEndDate;
@property (retain, nonatomic) IBOutlet UIDatePicker *dtPickerEnd;

@property (retain, nonatomic) IBOutlet UIView *viewType;
@property (retain, nonatomic) IBOutlet UIButton *btnType;

@property (retain, nonatomic) IBOutlet UIView *viewAttendees;
@property (retain, nonatomic) IBOutlet UIButton *btnAttendees;

@property (weak, nonatomic) IBOutlet UITextView *txtNote;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewContents;
@property (retain, nonatomic) IBOutlet UIView *viewScrollContents;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *constraitTopOfAttendee;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *constraitTopOfNote;

@end

@implementation AddWorkViewController

@synthesize startTime, endTime, isTestMode;
@synthesize initLabourTypeId;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIManager sharedInstance] applyDefaultTextViewStyle:self.txtNote];
    [[UIManager sharedInstance] applyViewBorder:self.viewStartDate borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [[UIManager sharedInstance] applyViewBorder:self.viewEndDate borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [[UIManager sharedInstance] applyViewBorder:self.viewType borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [[UIManager sharedInstance] applyViewBorder:self.viewAttendees borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [[UIManager sharedInstance] applyViewBorder:self.viewJob borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [[UIManager sharedInstance]  applyDisableCustomButtonStyle:self.btnStart];
    [[UIManager sharedInstance]  applyDisableCustomButtonStyle:self.btnEnd];
    
    selectedLabourTypes = 0;
    
    self.dtPickerStart.datePickerMode = UIDatePickerModeTime;
    self.dtPickerEnd.datePickerMode = UIDatePickerModeTime;
    
    [self.dtPickerStart setDate:startTime];
    [self.dtPickerEnd setDate:endTime];
    [self.btnStart setTitle:[self getDateWithFormat:startTime] forState:UIControlStateNormal];
    [self.btnEnd setTitle:[self getDateWithFormat:endTime] forState:UIControlStateNormal];
    [self.dtPickerStart addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    [self.dtPickerEnd addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    
    // UITextView placeholder
    self.txtNote.text = @"Note";
    self.txtNote.textColor = [UIColor lightGrayColor]; //optional
    [self.txtNote  setTextContainerInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    
    // init local variables
    [self initLocalVariable];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:NO];
    [UserContext sharedInstance].isNewEventWindow = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UserContext sharedInstance].isNewEventWindow = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initLocalVariable
{
    fInit_constraitTopOfAttendee = self.constraitTopOfAttendee.constant;
    fInit_constraitTopOfNote = self.constraitTopOfNote.constant;
    
    isCollapsedStartDate = YES;
    isCollapsedEndDate = YES;
    isCollapsedType = YES;
    isCollapsedAttendees = YES;
    
    isShowedAttendeeList = NO;
    
    isAllDay = NO;
    
    selectedJobId = kJobId_UNASSIGNED;
    selectedJobPostUnit = @"";
    selectedJobNote = @"";
    
    [UserContext sharedInstance].addEventWindowDelegate = self;
    
    
    [self registerForKeyboardNotifications];

    // get user list and labour type list
    SHOW_PROGRESS(@"Fetching data...");
    [[ServerManager sharedManager] getUserList:^(NSMutableArray *arrUserList) {
        [self loadAttendess:arrUserList];
        
        [[ServerManager sharedManager] getLabourType:^(NSMutableArray *arrLabourList) {
            HIDE_PROGRESS;
            
            
            
            [[UserContext sharedInstance] initLabourTypeArray:arrLabourList];
            [self loadTypeList:arrLabourList];
            
            selectedLabourTypes = initLabourTypeId;
            LabourType *item = (LabourType *)[typeArray objectAtIndex:[self getLabourTypeIndex:initLabourTypeId]];
            selectedLabourTypes = item.typeID;
            [self.btnType setTitle:item.typeName forState:UIControlStateNormal];

            
        } failure:^(NSString *failure) {
            HIDE_PROGRESS_WITH_FAILURE(failure);
            
        }];
    } failure:^(NSString *failure) {
        HIDE_PROGRESS_WITH_FAILURE(failure);
        
    }];
}

- (NSString *)getDateWithFormat:(NSDate *)date {
    NSString *formatDate = [NSString stringWithFormat:@"%@", date];
    formatDate = [NSString stringWithFormat:@"%@", [date toLocalTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd,yyyy h:mm a"];
    formatDate = [dateFormatter stringFromDate:date];
    
    return formatDate;
}


- (void)dateIsChanged:(UIDatePicker *)datePicker{
    NSLog(@"Selected date = %@", datePicker.date);
    if (datePicker == self.dtPickerStart) {
        
        startTime = datePicker.date;
        
        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[self getDateWithFormat:startTime]];
        
        if ([startTime isLaterThanDate:endTime] ) {
            [titleString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
        }
        [self.btnStart setAttributedTitle:titleString forState:UIControlStateNormal];
        
    }
    else if (datePicker == self.dtPickerEnd) {
        endTime = datePicker.date;
        
        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[self getDateWithFormat:endTime]];
        if ([endTime isEarlierThanDate:startTime] ) {
            [titleString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [titleString length])];
        }
        [self.btnEnd setAttributedTitle:titleString forState:UIControlStateNormal];
    }
}

// alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1)
    {
        JobSelectionViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selJobVC"];
        controller.delegate = self;
        
        controller.isTestMode = isTestMode;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}


- (IBAction)onCancelClicked:(id)sender {
    [self dismiss];
}

- (IBAction)onAddClicked:(id)sender {
    static NSUInteger insertCounter = 0;
    
    if (selectedJobId == kJobId_UNASSIGNED) {
        NSString *title = @"Job assign";
        NSString *message = @"Please select the job";
        
        UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil ];
        
        [alertView show];
        
        return;
    }

    
    SHOW_PROGRESS(@"Fetching data...");
    
    insertCounter = 0;
    
    
    int currUserId = [[AppContext sharedInstance] loadUserID];
    
    if (isAllDay) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        NSString *startDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                   (int)startTime.year, (int)startTime.month, (int)startTime.day, kDayWorkTime_BeginHour, kDayWorkTime_BeginMin];
        NSString *endDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00",
                                   (int)startTime.year, (int)startTime.month, (int)startTime.day, kDayWorkTime_EndHour, kDayWorkTime_EndMin];
        
        startTime = [dateFormat dateFromString:startDateTime];
        endTime = [dateFormat dateFromString:endDateTime];
    }   
    
    
    NSString *sheetDescription = self.txtNote.text;
    
    [[ServerManager sharedManager] insertTimesheet:currUserId
                                         startTime:startTime
                                           endTime:endTime
                                             jobID:selectedJobId
                                       companyName:selectedJobPostUnit
                                      labourTypeId:selectedLabourTypes
                                             notes:sheetDescription
                                           success:^(BOOL result)
     {
         
         // add other attendees
         
         if (attendeeSeletedArray.count > 0)
         {
             
             for (NSUInteger i = 0; i < attendeeSeletedArray.count; i++)
             {
                 NSString *currObj = [attendeeSeletedArray objectAtIndex:i];
                 
                 [[ServerManager sharedManager] insertTimesheet:(int)[currObj integerValue]
                                                      startTime:startTime
                                                        endTime:endTime
                                                          jobID:selectedJobId
                                                    companyName:selectedJobPostUnit
                                                   labourTypeId:selectedLabourTypes
                                                          notes:sheetDescription
                                                        success:^(BOOL result)
                  {
                      
                      // add other attendees
                      insertCounter = insertCounter + 1;
                      if (insertCounter >= attendeeSeletedArray.count) {
                          
                          HIDE_PROGRESS;
                          
                          [self dismiss];
                          
                      }
                      
                  } failure:^(NSString *failure)
                  {
                      HIDE_PROGRESS_WITH_FAILURE(failure);
                  } ];
             }
             
         }
         else
         {
             HIDE_PROGRESS;
             [self dismiss];
         }
     } failure:^(NSString *failure)
     {
         HIDE_PROGRESS;
     } ];
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Note"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Note";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

// UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


- (IBAction)onStartDateClicked:(id)sender {
    [self hideKeyboard];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if (isCollapsedStartDate) {
            self.dtPickerStart.hidden = NO;
            self.constraitTopOfEndDate.constant = kDatePickerHeight;
            [self.btnStart setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
            isCollapsedStartDate = NO;
            
            if (isCollapsedEndDate == NO) {
                self.dtPickerEnd.hidden = YES;
                self.constraitTopOfAttendee.constant = fInit_constraitTopOfAttendee;
                [self.btnEnd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                isCollapsedEndDate = YES;
            }
            
            CGRect newFrame = self.viewScrollContents.frame;
            
            newFrame.size.height += 300;
            self.viewScrollContents.frame = newFrame;
            
        }
        else
        {
            self.dtPickerStart.hidden = YES;
            self.constraitTopOfEndDate.constant = 0.0f;
            [self.btnStart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            isCollapsedStartDate = YES;
            
            CGRect newFrame = self.viewScrollContents.frame;
            
            newFrame.size.height -= 300;
            self.viewScrollContents.frame = newFrame;

        }
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)onEndDateClicked:(id)sender {
    [self hideKeyboard];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if (isCollapsedEndDate) {
            self.dtPickerEnd.hidden = NO;
            self.constraitTopOfAttendee.constant = kDatePickerHeight;
            [self.btnEnd setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            
            isCollapsedEndDate = NO;
            
            if (isCollapsedStartDate == NO) {
                self.dtPickerStart.hidden = YES;
                self.constraitTopOfEndDate.constant = 0.0f;
                [self.btnStart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                isCollapsedStartDate = YES;
            }
        }
        else
        {
            self.dtPickerEnd.hidden = YES;
            self.constraitTopOfAttendee.constant = fInit_constraitTopOfAttendee;
            [self.btnEnd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            isCollapsedEndDate = YES;
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)registerForKeyboardNotifications
{
    // Register for the events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark Keyboard state
//the Function that call when keyboard show.
- (void)keyboardWasShown:(NSNotification *)notif {
    CGSize _keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, _keyboardSize.height, 0.0f);
    
    if ([self.txtNote isFirstResponder]) {
        CGRect missingLabelRect = [self.txtNote.superview convertRect:self.txtNote.frame toView:self.view];
        if(self.view.frame.size.height - _keyboardSize.height < missingLabelRect.origin.y + missingLabelRect.size.height)
        {
            self.scrollViewContents.contentInset = contentInsets;
            self.scrollViewContents.scrollIndicatorInsets = contentInsets;
        }
        
        [self.scrollViewContents scrollRectToVisible:self.txtNote.frame animated:YES];
    }
}

//the Function that call when keyboard hide.
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    [self restoreScrollView];
}

- (void)restoreScrollView {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollViewContents.contentInset = contentInsets;
    self.scrollViewContents.scrollIndicatorInsets = contentInsets;
}


- (IBAction)onBkButtonClicked:(id)sender {
    [self hideKeyboard];
}

- (IBAction)onTypeClicked:(id)sender {
    [self hideKeyboard];

    SelLabourTypesViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selLabourTypesVC"];
    controller.arrTypes = typeArray;
    controller.selectedTypes = selectedLabourTypes;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didLabourTypeTap:(int)selTypeId {
    for (LabourType *item in typeArray) {
        if (item.typeID == selTypeId) {
            selectedLabourTypes = selTypeId;
            [self.btnType setTitle:item.typeName forState:UIControlStateNormal];
        }
    }
}


- (IBAction)onAttendeeClicked:(id)sender {
    
    [self hideKeyboard];
    
    SelAttendeesViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selAttendeesVC"];
    
    
    controller.arrAttendees = attendeeArray;
    controller.arrSelectedAttendees = attendeeSeletedArray;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)loadTypeList:(NSMutableArray *)arrTypes {
    if (arrTypes != nil) {
        typeArray = arrTypes;
        
        if (typeArray.count > 0) {
            LabourType *item = (LabourType *)[typeArray objectAtIndex:0];
            selectedLabourTypes = item.typeID;
            [self.btnType setTitle:item.typeName forState:UIControlStateNormal];
        }
    }
}

- (void)loadAttendess:(NSMutableArray *)arrUsers {
    attendeeArray = [[NSMutableArray alloc] init];
    attendeeSeletedArray = [[NSMutableArray alloc] init];
    // load all attendees
    if (arrUsers != nil) {
        attendeeArray = arrUsers;
    }
    
    // remove current user
    int currUserId = [[AppContext sharedInstance] loadUserID];
    for (UserInfo *oneUser in attendeeArray)
    {
        if (oneUser.userID == currUserId)
        {
            [attendeeArray removeObject:oneUser];
            break;
        }
    }
    
    for (UserInfo *key in attendeeArray) {
        BOOL isSelected = NO;
        
        for (UserInfo *keyed in attendeeSeletedArray) {
            if (key.userID == keyed.userID) {
                isSelected = YES;
            }
        }
        
        [attendeeSelectionStates setObject:[NSNumber numberWithBool:isSelected] forKey:[NSString stringWithFormat:@"%d", key.userID]];
    }
}


- (void)displaySelectedAttendees
{
    NSString *strTitle = @"None";
    
    if (attendeeSeletedArray.count > 0) {
        strTitle = [NSString stringWithFormat:@"%d Users", (int)attendeeSeletedArray.count];
    }
        
    [self.btnAttendees setTitle:strTitle forState:UIControlStateNormal];
    
    for (NSString *oneUser in attendeeSeletedArray)
    {
        NSLog(@"uid=%@\n", oneUser);
    }
}

- (NSUInteger)getLabourTypeIndex:(int)labourTypeId {
    
    NSUInteger index = 0;
    
    if (typeArray != nil) {
        for (index = 0; index < typeArray.count; index++) {
            
            LabourType *oneType = [typeArray objectAtIndex:index];
            
            if (oneType.typeID == labourTypeId)
                return index;
        }
    }

    return index;
}

- (IBAction)onChangedAllDay:(id)sender
{
    [self hideKeyboard];
    
    isAllDay = [sender isOn];
    
    if (isAllDay == YES) {
        
        // hide date selection
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            
            if (isCollapsedStartDate == NO) {
                self.dtPickerStart.hidden = YES;
                self.constraitTopOfEndDate.constant = 0.0f;
                [self.btnStart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                isCollapsedStartDate = YES;
                
                CGRect newFrame = self.viewScrollContents.frame;
                
                newFrame.size.height -= 300;
                self.viewScrollContents.frame = newFrame;
            }
            
            if (isCollapsedEndDate == NO) {
                self.dtPickerEnd.hidden = YES;
                self.constraitTopOfAttendee.constant = fInit_constraitTopOfAttendee;
                [self.btnEnd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                isCollapsedEndDate = YES;
            }
        } completion:^(BOOL finished) {
        }];
    }
    
    BOOL isTimeEnable = YES;
    isTimeEnable = (isAllDay == YES)? NO: YES;
    
    self.btnStart.enabled = isTimeEnable;
    self.btnEnd.enabled = isTimeEnable;
}

- (IBAction)onJobClicked:(id)sender {
    
    JobSelectionViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selJobVC"];
    controller.delegate = self;
    
    controller.isTestMode = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - JobSelectionViewControllerDelegate
- (void)didJobSelected:(int)selJobId postUnit:(NSString *)postUnit notes:(NSString *)notes {
    
    selectedJobId = selJobId;
    selectedJobPostUnit = [NSString stringWithFormat:@"%@", postUnit];
    selectedJobNote = [NSString stringWithFormat:@"%@", notes];
    
    self.lblJobTitle.text = [NSString stringWithFormat:@"%d - %@", selectedJobId, selectedJobPostUnit];
    self.lblJobDescription.text = [NSString stringWithFormat:@"%@", selectedJobNote];
    
    [self.btnJob setTitle:@"" forState:UIControlStateNormal];
}

//============================
//      NewEventWindow Delegate
//============================
- (void)updateNewEventWindow:(NSDate *)eventStartTime endTime:(NSDate*)eventEndTime initLabourTypeId:(int)labourTypeId
{
    startTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:eventStartTime];
    endTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:eventEndTime];
    initLabourTypeId = labourTypeId;
    
    isAllDay = NO;
    
    [self.switchAllDay setOn:isAllDay];
    
    self.btnStart.enabled = YES;
    self.btnEnd.enabled = YES;
    
    selectedLabourTypes = initLabourTypeId;
    LabourType *item = (LabourType *)[typeArray objectAtIndex:[self getLabourTypeIndex:initLabourTypeId]];
    selectedLabourTypes = item.typeID;
    [self.btnType setTitle:item.typeName forState:UIControlStateNormal];
    
    [self.dtPickerStart setDate:startTime];
    [self.dtPickerEnd setDate:endTime];
    [self.btnStart setTitle:[self getDateWithFormat:startTime] forState:UIControlStateNormal];
    [self.btnEnd setTitle:[self getDateWithFormat:endTime] forState:UIControlStateNormal];
}

//**************************************
//  SelAttendeesViewControllerDelegate
//**************************************
- (void)returnChoosedUserId:(NSMutableArray *)selectedAttendees {
    attendeeSeletedArray = [[NSMutableArray alloc] initWithArray:selectedAttendees];
    
    [self displaySelectedAttendees];
    
}


@end
