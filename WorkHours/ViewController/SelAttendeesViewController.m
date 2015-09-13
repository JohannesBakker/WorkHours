//
//  SelAttendeesViewController.m
//  WorkHours
//
//  Created by Admin on 7/24/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SelAttendeesViewController.h"
#import "UIManager.h"
#import "UserInfo.h"
#import "Constant.h"

@interface SelAttendeesViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    BOOL isSelectedAll;
    NSUInteger nSelectedUsers;
}


@property(retain, nonatomic) NSMutableDictionary *selectionStatusDic;
@property(retain, nonatomic) NSMutableArray *selectedEntriesArr;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *viewConnection;
@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblConnection;

@end

@implementation SelAttendeesViewController

@synthesize arrAttendees, arrSelectedAttendees;
@synthesize delegate;
@synthesize nConnections;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:YES];
    
    // status bar text color change with default color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onClickedDone:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
     */
    
    // hide navigationController
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:NO];
    
    // change view color with connection color
    self.view.backgroundColor = self.viewConnection.backgroundColor;
    
    // status bar text color change with white color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set Menu view's border
    [[UIManager sharedInstance] applyViewBorder:self.viewTitle borderColor:kViewBorderColor borderWidth:kViewBorderWidth];
    
    
    // set Connections
    self.lblConnection.text = [NSString stringWithFormat:@"%d", nConnections];
    
    
    isSelectedAll = NO;
    
    [self initSelectionInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onBackClicked:(id)sender {
    [self dismiss];
}

- (IBAction)onClickedDone:(id)sender {
    self.selectedEntriesArr = [NSMutableArray array];
    
    for (id key in [self.selectionStatusDic allKeys]) {
        
        if ([[self.selectionStatusDic objectForKey:key] boolValue]) {
            [self.selectedEntriesArr addObject:key];
        }
    }
    
    if (delegate)
    {
        [delegate returnChoosedUserId:self.selectedEntriesArr];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}





- (void)initSelectionInfo {
    NSUInteger selCounter = 0;
    
    self.selectionStatusDic = [[NSMutableDictionary alloc] init];
    
    if (arrAttendees.count == 0)
        return;
    
    for (UserInfo *key in arrAttendees)
    {
        BOOL isSelected = NO;
        
        for (NSString *keyed in arrSelectedAttendees) {
            NSString *szKey = [NSString stringWithFormat:@"%d", key.userID];
            
            if ([szKey isEqualToString:keyed]) {
                isSelected = YES;
                selCounter ++;
                break;
            }
        }
        
        [self.selectionStatusDic setObject:[NSNumber numberWithBool:isSelected] forKey:[NSString stringWithFormat:@"%d", key.userID]];
    }
    
    if (selCounter == arrAttendees.count)
        isSelectedAll = YES;
    else
        isSelectedAll = NO;
    
    nSelectedUsers = selCounter;
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
    // Return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrAttendees != nil && arrAttendees.count > 0)
        return arrAttendees.count + 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selAttendeesCell"];
    UILabel *labelUser = (UILabel *)[cell viewWithTag:200];
    UIImageView *ivSel = (UIImageView *)[cell viewWithTag:201];
    NSInteger actRow = indexPath.row - 1;
    
    if (actRow == -1)
    {
        // All Attendees
        labelUser.text = @"All";

        if (isSelectedAll) {
            ivSel.hidden = NO;
        }
        else {
            ivSel.hidden = YES;
        }
    }
    else {
        UserInfo *oneUser = [arrAttendees objectAtIndex:actRow];
        
        labelUser.text = [NSString stringWithFormat:@"%@ %@", oneUser.firstName, oneUser.lastName];
   
        if ([[self.selectionStatusDic objectForKey:[NSString stringWithFormat:@"%d", oneUser.userID]] boolValue]) {
            ivSel.hidden = NO;
        } else {
            ivSel.hidden = YES;
        }
    }
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger actRow = indexPath.row - 1;
    
    if (actRow == -1) {
        if (isSelectedAll == YES) {
            isSelectedAll = NO;
            
            nSelectedUsers = 0;
        }
        else {
            isSelectedAll = YES;
            
            nSelectedUsers = arrAttendees.count;
        }
        
        for (id key in [self.selectionStatusDic allKeys]) {
            [self.selectionStatusDic setObject:[NSNumber numberWithBool:isSelectedAll] forKey:key];
        }
    }
    else {
        UserInfo *oneUser = [arrAttendees objectAtIndex:actRow];
        BOOL isSelected = [[self.selectionStatusDic objectForKey:[NSString stringWithFormat:@"%d", oneUser.userID]] boolValue];
        
        if (isSelected == YES) {
            isSelected = NO;
            
            if (nSelectedUsers > 0)
                nSelectedUsers --;
        }
        else {
            isSelected = YES;
            
            if (nSelectedUsers < arrAttendees.count)
                nSelectedUsers ++;
        }
        
        [self.selectionStatusDic setObject:[NSNumber numberWithBool:isSelected] forKey:[NSString stringWithFormat:@"%d", oneUser.userID]];
        
        // check all selected
        if (nSelectedUsers == arrAttendees.count) {
            isSelectedAll = YES;
        } else {
            isSelectedAll = NO;
        }
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
       [tableView reloadData];
    });
}

@end
