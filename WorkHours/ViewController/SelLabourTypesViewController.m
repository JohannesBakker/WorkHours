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

@interface SelLabourTypesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelLabourTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIManager sharedInstance] isVisibleStatusBar:self.navigationController isShow:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
