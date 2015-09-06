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

#define kLabourId_UNASSIGNED      -1

#define kAlertType_NoJob        1
#define kAlertType_NoteEmpty    2

@interface AddWorkViewController () <UITextFieldDelegate, UIScrollViewDelegate, SelLabourTypesViewControllerDelegate, JobSelectionViewControllerDelegate, SelAttendeesViewControllerDelegate, NewEventWindowDelegate> {
    
    BOOL              isAllDay;               // Enable/Disable All day
    
    int         labourId;           // Labour ID
    NSDate*     startTime;          // labour Start time
    NSDate*     endTime;            // labour End time
    int         jobId;              // Job ID
    NSString*   companyName;        // Job Company name
    int         labourTypeId;       // Labour Type ID
    NSString*   labourDescription;  // Labour description
    
    NSString*   jobDescription;       // Job description
    
    
    BOOL bIsCollapsedStartDate;
    BOOL bIsCollapsedEndDate;
    BOOL bIsCollapsedType;
    BOOL bIsCollapsedAttendees;
    
    BOOL bIsShowedAttendeeList;
    BOOL bIsShowedHint;
    
    int  nAlertType;
    
    CGFloat fInit_constraitTopOfAttendee;
    CGFloat fInit_constraitTopOfNote;
    
    UITextField *activeTextField;
    CGFloat init_TopConstraint;
    CGSize g_keyboardSize;
    
    NSMutableArray *typeArray;
    
    NSMutableArray *attendeeArray;
    NSMutableArray *attendeeSeletedArray;
    NSMutableDictionary *attendeeSelectionStates;
    
    AppContext *appContext;
    UserContext *userContext;
    
    UIManager *uiManager;
}

// Title UI controls
@property (retain, nonatomic) IBOutlet UIButton *btnAddDone;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;


@property (retain, nonatomic) IBOutlet UIView *viewJobBackground;
@property (retain, nonatomic) IBOutlet UIView *viewJob;
@property (retain, nonatomic) IBOutlet UILabel *lblJobTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblJobDescription;
@property (retain, nonatomic) IBOutlet UILabel *lblJob;
@property (retain, nonatomic) IBOutlet UILabel *lblDate;
@property (retain, nonatomic) IBOutlet UILabel *lblStartTime;
@property (retain, nonatomic) IBOutlet UILabel *lblEndTime;
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

//@synthesize startTime, endTime, isTestMode;
//@synthesize initLabourTypeId;
@synthesize isTestMode;
@synthesize isNewEventMode;
//@synthesize sheet;


/*
@synthesize jobId, jobPostUnit, jobPostNotes;
@synthesize isAllDay;
@synthesize startTime, endTime;
@synthesize labourTypeId;
@synthesize note;
*/



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // UI object style setting
    uiManager = [UIManager sharedInstance];
    
    [uiManager applyDefaultTextViewStyle:self.txtNote];
    [uiManager applyViewBorder:self.viewStartDate borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [uiManager applyViewBorder:self.viewEndDate borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [uiManager applyViewBorder:self.viewType borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [uiManager applyViewBorder:self.viewAttendees borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [uiManager applyViewBorder:self.viewJob borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [uiManager applyViewBorder:self.viewJobBackground borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    [uiManager applyDisableCustomButtonStyle:self.btnStart];
    [uiManager applyDisableCustomButtonStyle:self.btnEnd];
    
    
    //*******************
    // customize UI
    //*******************
    
    // customize Title
    if (isNewEventMode) {
        self.lblTitle.text = @"New Event";
        [self.btnAddDone setTitle:@"Add" forState:UIControlStateNormal];
    } else {
        self.lblTitle.text = @"Edit Event";
        [self.btnAddDone setTitle:@"Done" forState:UIControlStateNormal];
    }
    
    // All-day UI
    [self.switchAllDay setOn:isAllDay];
    
    // Start/End Time UI
    self.dtPickerStart.datePickerMode = UIDatePickerModeTime;
    self.dtPickerEnd.datePickerMode = UIDatePickerModeTime;
    
    [self.dtPickerStart setDate:startTime];
    [self.dtPickerEnd setDate:endTime];
    
    self.lblDate.text = [self getDateWithFormat:startTime];
    self.lblStartTime.text = [self getTimeWithFormat:startTime];
    self.lblEndTime.text = [self getTimeWithFormat:endTime];

    
    [self.dtPickerStart addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    [self.dtPickerEnd addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.btnStart.enabled = !isAllDay;
    self.btnEnd.enabled = !isAllDay;
    
    // Attendees Enable/Disable
    if (isNewEventMode) {
        [self.btnAttendees setEnabled:YES];
    } else {
        [self.btnAttendees setEnabled:NO];
    }
    
    // Note
    if (labourDescription.length > 0) {
        self.txtNote.text = labourDescription;
        bIsShowedHint = NO;
    } else {
        self.txtNote.text = @"Note";
        self.txtNote.textColor = [UIColor lightGrayColor]; //optional
        bIsShowedHint = YES;
    }
    
    [self.txtNote  setTextContainerInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    
    
    // init local variables
    [self initLocalVariable];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [uiManager isVisibleStatusBar:self.navigationController isShow:NO];
    userContext.isNewEventWindow = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    userContext.isNewEventWindow = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//*****************************
// Action functions
//*****************************

// Cancel clicking event
- (IBAction)onCancelClicked:(id)sender {
    [self dismiss];
}

// Add/Done clicking event
- (IBAction)onAddDoneClicked:(id)sender {
    
    if (jobId == kJobId_UNASSIGNED) {
        
        NSString *title = @"Job assign";
        NSString *message = @"Please select the job";
        
        nAlertType = kAlertType_NoJob;
        
        UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil ];
        [alertView show];
        return;
    }
    
    if (bIsShowedHint) {
        NSString *title = @"Note empty";
        NSString *message = @"Please input notes";
        
        nAlertType = kAlertType_NoteEmpty;
        
        UIAlertView *alertView = [ [UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil ];
        [alertView show];
        return;
    }
    
    int currUserId = [appContext loadUserID];
    
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
    
    if (isNewEventMode) {
        
        // event add/change
        [self addNewEvent:currUserId
           eventStartTime:startTime
             eventEndTime:endTime
                    jobID:jobId
              jobPostUnit:companyName
             labourTypeID:labourTypeId
                    notes:sheetDescription];
    }else {
        // change event
        [self changeEvent:labourId
           eventStartTime:startTime
             eventEndTime:endTime
                    jobID:jobId
             labourTypeID:labourTypeId
                    notes:sheetDescription];
    }
}


// background clicking event
- (IBAction)onBkButtonClicked:(id)sender {
    [self hideKeyboard];
}

// Job clicking event
- (IBAction)onJobClicked:(id)sender {
    
    JobSelectionViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selJobVC"];
    controller.delegate = self;
    
    controller.isTestMode = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
}

// All-day clicking event
- (IBAction)onChangedAllDay:(id)sender
{
    [self hideKeyboard];
    
    isAllDay = [sender isOn];
    
    if (isAllDay == YES) {
        
        // hide date selection
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            
            if (bIsCollapsedStartDate == NO) {
                self.dtPickerStart.hidden = YES;
                self.constraitTopOfEndDate.constant = 0.0f;
                self.lblStartTime.textColor = [UIColor blackColor];
                
                bIsCollapsedStartDate = YES;
            }
            
            if (bIsCollapsedEndDate == NO) {
                self.dtPickerEnd.hidden = YES;
                self.constraitTopOfAttendee.constant = fInit_constraitTopOfAttendee;
                self.lblEndTime.textColor = [UIColor blackColor];
                
                bIsCollapsedEndDate = YES;
            }
        } completion:^(BOOL finished) {
        }];
    }
    
    self.btnStart.enabled = !isAllDay;
    self.btnEnd.enabled = !isAllDay;
    
    // change color of start/end time label
    if (isAllDay) {
        self.lblStartTime.textColor = kButtonDisableTitleColor;
        self.lblEndTime.textColor = kButtonDisableTitleColor;
    }
    else {
        self.lblStartTime.textColor = [UIColor blackColor];
        self.lblEndTime.textColor = [UIColor blackColor];
    }
}


// Start time clicking event
- (IBAction)onStartDateClicked:(id)sender {
    [self hideKeyboard];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if (bIsCollapsedStartDate) {
            self.dtPickerStart.hidden = NO;
            self.constraitTopOfEndDate.constant = kDatePickerHeight;
            self.lblStartTime.textColor = [UIColor redColor];
            
            bIsCollapsedStartDate = NO;
            
            if (bIsCollapsedEndDate == NO) {
                self.dtPickerEnd.hidden = YES;
                self.constraitTopOfAttendee.constant = fInit_constraitTopOfAttendee;
                self.lblEndTime.textColor = [UIColor blackColor];
                
                bIsCollapsedEndDate = YES;
            }
        }
        else
        {
            self.dtPickerStart.hidden = YES;
            self.constraitTopOfEndDate.constant = 0.0f;
            self.lblStartTime.textColor = [UIColor blackColor];
            
            bIsCollapsedStartDate = YES;
        }
    } completion:^(BOOL finished) {
    }];
}

// End time clicking event
- (IBAction)onEndDateClicked:(id)sender {
    [self hideKeyboard];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if (bIsCollapsedEndDate) {
            self.dtPickerEnd.hidden = NO;
            self.constraitTopOfAttendee.constant = kDatePickerHeight;
            self.lblEndTime.textColor = [UIColor redColor];
            
            bIsCollapsedEndDate = NO;
            
            if (bIsCollapsedStartDate == NO) {
                self.dtPickerStart.hidden = YES;
                self.constraitTopOfEndDate.constant = 0.0f;
                self.lblStartTime.textColor = [UIColor blackColor];
                
                bIsCollapsedStartDate = YES;
            }
        }
        else
        {
            self.dtPickerEnd.hidden = YES;
            self.constraitTopOfAttendee.constant = fInit_constraitTopOfAttendee;
            self.lblEndTime.textColor = [UIColor blackColor];
            
            bIsCollapsedEndDate = YES;
        }
    } completion:^(BOOL finished) {
    }];
}

// date picker selecting function
- (void)dateIsChanged:(UIDatePicker *)datePicker{
    NSLog(@"Selected date = %@", datePicker.date);
    if (datePicker == self.dtPickerStart) {
        
        startTime = datePicker.date;
        
        NSMutableAttributedString *startTimeString = [[NSMutableAttributedString alloc] initWithString:[self getTimeWithFormat:startTime]];
        
        if ([startTime isLaterThanDate:endTime] ) {
            [startTimeString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [startTimeString length])];
            
            // restore endTime label
            NSMutableAttributedString *endTimeString = [[NSMutableAttributedString alloc] initWithString:[self getTimeWithFormat:endTime]];
            [self.lblEndTime setAttributedText:endTimeString];
        }
        
        [self.lblStartTime setAttributedText:startTimeString];
    }
    else if (datePicker == self.dtPickerEnd) {
        endTime = datePicker.date;
        
        NSMutableAttributedString *endTimeString = [[NSMutableAttributedString alloc] initWithString:[self getTimeWithFormat:endTime]];
        if ([endTime isEarlierThanDate:startTime] ) {
            [endTimeString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [endTimeString length])];
            
            // restore startTime label
            NSMutableAttributedString *startTimeString = [[NSMutableAttributedString alloc] initWithString:[self getTimeWithFormat:startTime]];
            [self.lblStartTime setAttributedText:startTimeString];
        }
        
        [self.lblEndTime setAttributedText:endTimeString];
    }
}

// Attendees clicking event
- (IBAction)onAttendeeClicked:(id)sender {
    
    [self hideKeyboard];
    
    SelAttendeesViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selAttendeesVC"];
    
    controller.arrAttendees = attendeeArray;
    controller.arrSelectedAttendees = attendeeSeletedArray;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}


// Labour type clicking event
- (IBAction)onTypeClicked:(id)sender {
    [self hideKeyboard];
    
    SelLabourTypesViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selLabourTypesVC"];
    controller.arrTypes = typeArray;
    controller.selectedTypes = labourTypeId;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}


//*****************************
// Local functions
//*****************************

// init local variables
- (void)initLocalVariable
{
    appContext = [AppContext sharedInstance];
    userContext = [UserContext sharedInstance];
    userContext.addEventWindowDelegate = self;
    
    fInit_constraitTopOfAttendee = self.constraitTopOfAttendee.constant;
    fInit_constraitTopOfNote = self.constraitTopOfNote.constant;
    
    bIsCollapsedStartDate = YES;
    bIsCollapsedEndDate = YES;
    bIsCollapsedType = YES;
    bIsCollapsedAttendees = YES;
    
    bIsShowedAttendeeList = NO;

    [self registerForKeyboardNotifications];

    // get user list and labour type list
    SHOW_PROGRESS(@"Fetching data...");
    [[ServerManager sharedManager] getUserList:^(NSMutableArray *arrUserList) {
        
        // load attendees
        {
            attendeeArray = arrUserList;
            attendeeSeletedArray = [[NSMutableArray alloc] init];

            // load all attendees
            
            // remove current user
            int currUserId = [appContext loadUserID];
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
        
        typeArray = [UserContext sharedInstance].arrLabourType;
        LabourType *item = [[UserContext sharedInstance] getLabourType:labourTypeId];;;
        labourTypeId = item.typeID;
        [self.btnType setTitle:item.typeName forState:UIControlStateNormal];
        
        // download jobs and display selected job
        [self downloadJobs];
        
    } failure:^(NSString *failure) {
        HIDE_PROGRESS_WITH_FAILURE(failure);
        
    }];
}

// get date string format
- (NSString *)getDateWithFormat:(NSDate *)date {
    NSString *formatDate = [NSString stringWithFormat:@"%@", date];
    formatDate = [NSString stringWithFormat:@"%@", [date toLocalTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    formatDate = [dateFormatter stringFromDate:date];
    
    return formatDate;
}

// get time string format
- (NSString *)getTimeWithFormat:(NSDate *)date {
    NSString *formatDate = [NSString stringWithFormat:@"%@", date];
    formatDate = [NSString stringWithFormat:@"%@", [date toLocalTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    formatDate = [dateFormatter stringFromDate:date];
    
    return formatDate;
}


// display Job
- (void)displayJobs:(int)selJobId postUnit:(NSString *)postUnit jobNotes:(NSString *)jobNotes {
    jobId = selJobId;
    companyName = [NSString stringWithString:postUnit];
    jobDescription = [NSString stringWithString:jobNotes];
    
    if (jobId == kJobId_UNASSIGNED) {
        self.lblJob.hidden = NO;
        self.lblJobTitle.text = @"";
        self.lblJobDescription.text = @"";
        
    } else {
        self.lblJob.hidden = YES;
        self.lblJobTitle.text = [NSString stringWithFormat:@"%d - %@", jobId, companyName];
        self.lblJobDescription.text = [NSString stringWithFormat:@"%@", jobDescription];
    }
}

- (void)displayJob:(int)selJobId {
    jobId = selJobId;
    
    Job *oneJob = [[UserContext sharedInstance] getJob:jobId];
    
    if (oneJob == nil) {
        companyName = @"";
        jobDescription = @"";
        
        self.lblJob.hidden = NO;
        self.lblJobTitle.text = @"";
        self.lblJobDescription.text = @"";
    }
    else {
        companyName = [NSString stringWithString:oneJob.companyName];
        jobDescription = [NSString stringWithString:oneJob.notes];
        
        self.lblJob.hidden = YES;
        self.lblJobTitle.text = [NSString stringWithFormat:@"%d - %@", jobId, companyName];
        self.lblJobDescription.text = [NSString stringWithFormat:@"%@", jobDescription];
    }
    
}

- (void)downloadJobs {
    
    double lat = [appContext loadUserLocationLat];
    double lon = [appContext loadUserLocationLng];
    
    if (isTestMode) {
        lat = -33.831370;
        lon = 151.200818;
    }
    
    [ [ServerManager sharedManager] getJobsByLocation:lat lon:lon success:^(NSMutableArray *arrJobList)
     {
         HIDE_PROGRESS;
         [[UserContext sharedInstance] initJobs:arrJobList];
         
         // display Job
         [self displayJob:jobId];
         
     } failure:^(NSString *failure)
     {
         HIDE_PROGRESS_WITH_FAILURE(failure);
         
         // display Job
         [self displayJob:jobId];
     } ];
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

// add new event function
- (void)addNewEvent:(int)userId eventStartTime:(NSDate*)eventStartTime eventEndTime:(NSDate*)eventEndTime jobID:(int)jobID jobPostUnit:(NSString*)jobPostUnit labourTypeID:(int)labourTypeID notes:(NSString*)notes
{
    static NSUInteger insertCounter = 0;
    
    insertCounter = 0;
    
    SHOW_PROGRESS(@"Fetching data...");

    
    [[ServerManager sharedManager] insertTimesheet:userId
                                         startTime:eventStartTime
                                           endTime:eventEndTime
                                             jobID:jobID
                                       companyName:jobPostUnit
                                      labourTypeId:labourTypeID
                                             notes:notes
                                           success:^(BOOL result)
     {
         
         // add other attendees
         
         HIDE_PROGRESS;
         [self dismiss];
         
         /*
         if (attendeeSeletedArray.count > 0) {
             
             for (NSUInteger i = 0; i < attendeeSeletedArray.count; i++) {
                 NSString *currObj = [attendeeSeletedArray objectAtIndex:i];
                 
                 [[ServerManager sharedManager] insertTimesheet:(int)[currObj integerValue]
                                                      startTime:eventStartTime
                                                        endTime:eventEndTime
                                                          jobID:jobID
                                                    companyName:companyName
                                                   labourTypeId:labourTypeID
                                                          notes:notes
                                                        success:^(BOOL result)
                  {
                      
                      // add other attendees
                      insertCounter = insertCounter + 1;
                      if (insertCounter >= attendeeSeletedArray.count) {
                          
                          HIDE_PROGRESS;
                          
                          [self dismiss];
                      }
                      
                  } failure:^(NSString *failure) {
                      HIDE_PROGRESS_WITH_FAILURE(failure);
                  } ];
             }
             
         }
         else {
             
             HIDE_PROGRESS;
             [self dismiss];
         }
         
         */
     } failure:^(NSString *failure)
     {
         HIDE_PROGRESS;
     } ];
    
}


// add new event function
- (void)changeEvent:(int)labourID eventStartTime:(NSDate*)eventStartTime eventEndTime:(NSDate*)eventEndTime jobID:(int)jobID labourTypeID:(int)labourTypeID notes:(NSString*)notes
{
    static NSUInteger insertCounter = 0;
    
    insertCounter = 0;
    
    SHOW_PROGRESS(@"Fetching data...");
    
    
    [[ServerManager sharedManager] changetimesheet:labourID
                                   updateStartTime:eventStartTime
                                     updateEndTime:eventEndTime
                                             jobID:jobID
                                      labourTypeId:labourTypeID
                                             notes:notes
                                           success:^(BOOL result)
    {
        HIDE_PROGRESS;
        
        [self dismiss];
                                               
        
    } failure:^(NSString *failure)
    {
        HIDE_PROGRESS_WITH_FAILURE(failure);
        
    } ];
}


//*****************************************************
//     alert view
//*****************************************************

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1)
    {
        if (nAlertType == kAlertType_NoJob) {
            JobSelectionViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"selJobVC"];
            controller.delegate = self;
            
            controller.isTestMode = isTestMode;
            
            [self.navigationController pushViewController:controller animated:YES];
            
        }
        else if (nAlertType == kAlertType_NoteEmpty) {
            // set focus to note
            [self.txtNote becomeFirstResponder];
        }
        
    }
}

//*****************************************************
//     UITextField delegate
//*****************************************************

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (bIsShowedHint == YES
        /*[textView.text isEqualToString:@"Note"]*/) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        bIsShowedHint = NO;
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Note";
        textView.textColor = [UIColor lightGrayColor]; //optional
        bIsShowedHint = YES;
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

    // restore scrollview
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollViewContents.contentInset = contentInsets;
    self.scrollViewContents.scrollIndicatorInsets = contentInsets;
}


//*****************************************************
//     SelLabourTypesViewControllerDelegate functions
//*****************************************************

- (void)didLabourTypeTap:(int)selTypeId {
    for (LabourType *item in typeArray) {
        if (item.typeID == selTypeId) {
            labourTypeId = selTypeId;
            [self.btnType setTitle:item.typeName forState:UIControlStateNormal];
        }
    }
}

//*****************************************************
//     SelAttendeesViewControllerDelegate
//*****************************************************
- (void)returnChoosedUserId:(NSMutableArray *)selectedAttendees {
    
    // display selected attendees
    
    attendeeSeletedArray = [[NSMutableArray alloc] initWithArray:selectedAttendees];
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

//*****************************************************
//     JobSelectionViewControllerDelegate
//*****************************************************

#pragma mark - JobSelectionViewControllerDelegate
- (void)didJobSelected:(int)selJobId postUnit:(NSString *)postUnit notes:(NSString *)notes {
    
    [self displayJobs:selJobId postUnit:postUnit jobNotes:notes];
}

//*****************************************************
//      NewEventWindow Delegate
//*****************************************************
- (void)updateNewEventWindow:(NSDate *)eventStartTime endTime:(NSDate*)eventEndTime initLabourTypeId:(int)typeId
{
    startTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:eventStartTime];
    endTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:eventEndTime];
    
    isAllDay = NO;
    
    [self.switchAllDay setOn:isAllDay];
    
    self.btnStart.enabled = YES;
    self.btnEnd.enabled = YES;
    
    LabourType *item = [[UserContext sharedInstance] getLabourType:typeId];
    labourTypeId = item.typeID;
    [self.btnType setTitle:item.typeName forState:UIControlStateNormal];
    
    [self.dtPickerStart setDate:startTime];
    [self.dtPickerEnd setDate:endTime];
    
    self.lblDate.text = [self getDateWithFormat:startTime];
    self.lblStartTime.text = [self getTimeWithFormat:startTime];
    self.lblEndTime.text = [self getTimeWithFormat:endTime];
}

//*****************************************************
//      Pubilc functions
//*****************************************************
- (void)createNewEvent:(NSDate*)eventStartTime eventEndTime:(NSDate*)eventEndTime labourTypeID:(int)labourTypeID
{
    isNewEventMode = YES;
    
    isAllDay = NO;
    
    labourId = kLabourId_UNASSIGNED;
    startTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:eventStartTime];
    endTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:eventEndTime];
    jobId = kJobId_UNASSIGNED;
    companyName = @"";
    labourTypeId = labourTypeID;
    labourDescription = @"";
}

- (void)editSelectEvent:(TimeSheet *)selectedSheet
{
    isNewEventMode = NO;
    
    isAllDay = NO;
    
    labourId = selectedSheet.labourID;
    startTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:selectedSheet.startTime];
    endTime = [[NSDate alloc] initWithTimeInterval:0 sinceDate:selectedSheet.endTime];
    jobId = selectedSheet.jobID;
    companyName = [NSString stringWithString:selectedSheet.companyName];
    labourTypeId = selectedSheet.labourTypeID;
    labourDescription = [NSString stringWithString:selectedSheet.labourDescription];
}
@end
