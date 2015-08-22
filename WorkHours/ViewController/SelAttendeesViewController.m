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

@interface SelAttendeesViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    BOOL isSelectedAll;
}


@property(retain, nonatomic) NSMutableDictionary *selectionStatusDic;
@property(retain, nonatomic) NSMutableArray *selectedEntriesArr;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelAttendeesViewController

@synthesize arrAttendees, arrSelectedAttendees;
@synthesize delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:YES];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onClickedDone:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    isSelectedAll = NO;
    
    [self initSelectionInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

        if (isSelectedAll)
            ivSel.hidden = NO;
        else
            ivSel.hidden = YES;
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
        }
        else {
            isSelectedAll = YES;
        }
        
        for (id key in [self.selectionStatusDic allKeys]) {
            [self.selectionStatusDic setObject:[NSNumber numberWithBool:isSelectedAll] forKey:key];
        }
    }
    else {
        UserInfo *oneUser = [arrAttendees objectAtIndex:actRow];
        BOOL isSelected = [[self.selectionStatusDic objectForKey:[NSString stringWithFormat:@"%d", oneUser.userID]] boolValue];
        
        if (isSelected == YES)
            isSelected = NO;
        else
            isSelected = YES;
        
        [self.selectionStatusDic setObject:[NSNumber numberWithBool:isSelected] forKey:[NSString stringWithFormat:@"%d", oneUser.userID]];
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
       [tableView reloadData];
    });
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



@end
