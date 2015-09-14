//
//  JobSelectionViewController.m
//  WorkHours
//
//  Created by Admin on 7/18/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "JobSelectionViewController.h"
#import "JobNumberCell.h"
#import "JobDistanceCell.h"
#import "ServerManager.h"
#import "Job.h"
#import "UserContext.h"
#import "AppContext.h"
#import "SVProgressHUD+WorkHours.h"
#import "UIManager.h"
#import "Constant.h"

#define kJobCellHeight      70.0f

#define kAnimationDuration      2.0f

@interface JobSelectionViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate,   UITableViewDelegate, UITableViewDataSource, JobNumberCellDelegate, JobDistanceCellDelegate> {
    NSMutableArray *arrJobs;
    NSMutableArray *arrFilterJobs;
    BOOL isDisplayByNumber;
    
    float init_constrait;
}


@property (weak, nonatomic) IBOutlet UITableView *viewJobs;
@property (retain, nonatomic) IBOutlet UIView *viewTitle;

@property (weak, nonatomic) IBOutlet UIView *viewConnection;
@property (weak, nonatomic) IBOutlet UILabel *lblConnection;

@property (weak, nonatomic) IBOutlet UIView *viewJobNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtJobNumber;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *constraitTopOfJobNumber;



@end

@implementation JobSelectionViewController

@synthesize nConnections;


@synthesize isTestMode;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isDisplayByNumber = YES;
    
    // set Title view's border
    [[UIManager sharedInstance] applyViewBorder:self.viewTitle borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    
    // Keyboard hiding registering
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // register textfield notification
    [self registerForTextFieldNotifications];

    // change view color with connection color
    self.view.backgroundColor = self.viewConnection.backgroundColor;
    
    // status bar text color change with white color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set Connections
    self.lblConnection.text = [NSString stringWithFormat:@"%d", nConnections];
    
    // show Job number text box
    init_constrait = self.constraitTopOfJobNumber.constant;
    [self showJobNumber];
    
    // remove tableviewcell separator line
    self.viewJobs.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //========================
    // init local variables
    //========================
    
    // current VC is JobSelectionViewController
    [[UserContext sharedInstance] setActiveVC:VC_JOB_SELECTION];
    
    arrJobs = [UserContext sharedInstance].arrJobs;
    [self resortJobs];

    [self.viewJobs reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resortJobs {
    
    if (arrJobs == nil || arrJobs.count == 0)
        return;
    
    NSString *sortKey;
    
    if (isDisplayByNumber)
        sortKey = @"jobID";
    else
        sortKey = @"distance";
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [arrJobs sortUsingDescriptors:sortDescriptors];
    
    if (isDisplayByNumber) {
        [self filterJobs:self.txtJobNumber.text];
    } else {
        [self filterJobs:@""];
    }
}

- (void)showJobNumber {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if (isDisplayByNumber) {
            self.constraitTopOfJobNumber.constant = init_constrait;
        }
        else
        {
            self.constraitTopOfJobNumber.constant = init_constrait - self.viewJobNumber.frame.size.height;
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissKeyboard {
    [self.txtJobNumber resignFirstResponder];
}

- (void)filterJobs:(NSString *)szJobNumber {
    if (szJobNumber == nil || szJobNumber.length == 0) {
        arrFilterJobs = [[NSMutableArray alloc] initWithArray:arrJobs];
    } else {
        
        arrFilterJobs = [NSMutableArray array];
        
        for (int i = 0; i < arrJobs.count; i++) {
            Job *currJob = [arrJobs objectAtIndex:i];
            NSString *currJobNumber = [NSString stringWithFormat:@"%d", currJob.jobID];
            
            if ([currJobNumber rangeOfString:szJobNumber].location == NSNotFound) {
                
            } else {
                [arrFilterJobs addObject:currJob];
            }
        }
    }
}


////////////////////////////////////////////////////////////
// Action methods
////////////////////////////////////////////////////////////
- (IBAction)onBackClicked:(id)sender {
    [self dismiss];
}

- (IBAction)onChangedSortType:(id)sender {
    UISegmentedControl *segType = (UISegmentedControl*)sender;
    
    if (segType.selectedSegmentIndex == 0)
        isDisplayByNumber = YES;
    else
        isDisplayByNumber = NO;
    
    // Show/Hide Job number text box
    [self showJobNumber];
    
    [self resortJobs];
    [self.viewJobs reloadData];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (arrFilterJobs && arrFilterJobs.count > 0)
        return arrFilterJobs.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = kJobCellHeight;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Job *currJob = [arrFilterJobs objectAtIndex:indexPath.row];
    
    if (isDisplayByNumber) {
        JobNumberCell *cell = (JobNumberCell*)[tableView dequeueReusableCellWithIdentifier:@"JobNumberCell"];
        
        [cell initCellData:currJob.jobID jobPostUnit:currJob.companyName jobDescription:currJob.notes distance:currJob.distance];
        cell.delegate = self;
        
        // set cell border
        [[UIManager sharedInstance] applyViewBorder:cell.contentView borderColor:kCellBorderColor borderWidth:kCellBorderWidth];
        
        return cell;
        
    }
    
    JobDistanceCell *cell = (JobDistanceCell*)[tableView dequeueReusableCellWithIdentifier:@"JobDistanceCell"];
    
    [cell initCellData:currJob.jobID jobPostUnit:currJob.companyName jobDescription:currJob.notes distance:currJob.distance];
    cell.delegate = self;
    
    // set cell border
    [[UIManager sharedInstance] applyViewBorder:cell.contentView borderColor:kCellBorderColor borderWidth:kCellBorderWidth];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Job *selJob = [arrFilterJobs objectAtIndex:indexPath.row];
    
    if (self.delegate) {
        [self.delegate didJobSelected:selJob.jobID postUnit:selJob.companyName notes:selJob.notes];
        
        [self dismiss];
    }
}


////////////////////////////////////////////////////////////
// UIGestureRecognizerDelegate methods
////////////////////////////////////////////////////////////

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([touch.view isDescendantOfView:self.viewJobs]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

////////////////////////////////////////////////////////////
// UITextField Notification methods
////////////////////////////////////////////////////////////
-(void)registerForTextFieldNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector (handle_TextFieldTextChanged:)
                               name:UITextFieldTextDidChangeNotification
                             object:self.txtJobNumber];
    
}


- (void) handle_TextFieldTextChanged:(id)notification {
    [self filterJobs:self.txtJobNumber.text];
    [self.viewJobs reloadData];
}


@end
