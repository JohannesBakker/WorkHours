//
//  SelLabourTypesViewController.m
//  WorkHours
//
//  Created by Admin on 7/9/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "SelLabourTypesViewController.h"
#import "UIManager.h"
#import "LabourType.h"
#import "Constant.h"

@interface SelLabourTypesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *viewConnection;
@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblConnection;


@end

@implementation SelLabourTypesViewController

@synthesize nConnections;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:YES];
    
    // hide navigationController
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:NO];
    
    // status bar text color change with default color
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // change view color with connection color
    self.view.backgroundColor = self.viewConnection.backgroundColor;
    
    // status bar text color change with white color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // set Menu view's border
    [[UIManager sharedInstance] applyViewBorder:self.viewTitle borderColor:kViewBorderColor borderWidth:kViewBorderWidth];

    
    // set Connections
    self.lblConnection.text = [NSString stringWithFormat:@"%d", nConnections];
    
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
    return self.arrTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selLabourTypeCell"];
    UILabel *labelType = (UILabel *)[cell viewWithTag:100];
    LabourType *item = [self.arrTypes objectAtIndex:indexPath.row];
    labelType.text = item.typeName;
    UIImageView *ivSel = (UIImageView *)[cell viewWithTag:101];
    if (self.selectedTypes == item.typeID) {
        ivSel.image = [UIImage imageNamed:@"icon_redmark"];
    } else {
        ivSel.image = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LabourType *item = [self.arrTypes objectAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate didLabourTypeTap:item.typeID];
        
        [self dismiss];
    }
}

@end
