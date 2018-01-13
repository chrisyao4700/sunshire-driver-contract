//
//  ProfileViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/23/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ProfileViewController.h"
#import "CYFunctionSet.h"
@interface ProfileViewController ()

@end

@implementation ProfileViewController{
    SS_CONTRACT_USER * defaultUser;
    BOOL passcode_edited;
    UIAlertController * alert;
    CurrentUserManager * userManager;
    UIActivityIndicatorView * loadingView;
    
    NSString * temp_passcode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    defaultUser = [CurrentUserManager getCurrentContractUser];
    [self setNavigationBarString:@"ME"];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 4;
    }
    if (section == 1) {
        temp = 2;
    }
    if (section == 2) {
        temp = 1;
    }
    return temp;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"基础信息";
    }
    if (section == 1) {
        temp = @"登录信息";
    }
    if (section == 2) {
        temp = @" ";
    }
    return temp;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        //headerView.contentView.backgroundColor = [UIColor colorWithWhite:10 alpha:0.3];
        //[headerView.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:25]];
        headerView.textLabel.textColor = [UIColor grayColor];
        headerView.contentView.backgroundColor = [UIColor clearColor];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"profile_cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //[cell.detailTextLabel setFont:[UIFont fontWithName:<#(nonnull NSString *)#> size:<#(CGFloat)#>]]
    if (indexPath.section == 0) {
        cell.userInteractionEnabled = YES;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"姓名:";
            cell.detailTextLabel.text = defaultUser.name;
        }

        if (indexPath.row == 1) {
            cell.textLabel.text = @"电话:";
            cell.detailTextLabel.text = defaultUser.phone;
            
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = @"电邮:";
            cell.detailTextLabel.text = defaultUser.email;
            
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = @"薪资率:";
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%.2f %%", defaultUser.salary_percentage.doubleValue * 100];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"用户名:";
            cell.detailTextLabel.text = defaultUser.username;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"密码:";
            if (passcode_edited == YES) {
                cell.detailTextLabel.text = temp_passcode;
            }else{
                cell.detailTextLabel.text = @"**##**";
            }
            
        }

    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.userInteractionEnabled = YES;
            cell.textLabel.text = @"登出";
            cell.detailTextLabel.text = @" ";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"name" forValue:defaultUser.name forCustomerTag:5];
        }
        if (indexPath.row == 1) {
            [self performAlertViewTextModifyWithKey:@"phone" forValue:defaultUser.phone forCustomerTag:5];
        }
        if (indexPath.row == 2) {
            [self performAlertViewTextModifyWithKey:@"email" forValue:defaultUser.email forCustomerTag:5];
        }
        
    }
    
    
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"username" forValue:defaultUser.username forCustomerTag:5];
        }
        if (indexPath.row == 1) {
            [self performAlertViewTextModifyWithKey:@"password" forValue:@"**##**" forCustomerTag:6];
        }

    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //[self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
-(void) reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.profileTable reloadData];
    });
}
-(void) performAlertViewTextModifyWithKey:(NSString *) key
                                 forValue:(NSString *) value
                           forCustomerTag:(NSInteger) c_tag{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        alert = [UIAlertController
                 alertControllerWithTitle:key
                 message:value
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self reloadTableView];
                                                             }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             //[locationHandler updateGasPoint];
                                                             NSString * value = [[alert.textFields objectAtIndex:0] text];
                                                             [self didSaveTextForKey:key andValue:value andCustomerTag:c_tag];                                                         }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"New information here...";
            if (![key isEqualToString:@"password"]) {
                textField.text = value;
            }
            
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
    });
}
-(void) didSaveTextForKey:(NSString *) key
                 andValue:(NSString *) value
           andCustomerTag:(NSInteger) c_tag{
    if (!userManager) {
        userManager = [[CurrentUserManager alloc] initWithDelegate:self];
    }
    if (c_tag == 6) {
        temp_passcode = value;
        value = [CYFunctionSet md5:value];
        passcode_edited = YES;
    }
    
    NSMutableArray * temp = [[NSMutableArray alloc] init];
    [temp addObject:@{
                      @"key" : key,
                      @"value": value}];
    NSDictionary * uploadpack = @{
                                  @"table_name": @"driver",
                                  @"element_array":(NSArray *)temp,
                                  @"data_id": defaultUser.data_id
                                  };
    [userManager updateCurrentUserWithPack:uploadpack];
}

-(void) currentUserManagerWillStartRequestWithTag:(NSInteger) tag{
    [self loadingStart];
}
-(void) currentUserManagerDidGetResponseWithTag:(NSInteger) tag{
    [self loadingStop];
}
-(void) currentUserManagerError:(NSString *) messsage
                         forTag:(NSInteger)tag{
    [self showAlertWithTittle:@"错误❌" forMessage:messsage];
}
-(void) currentUserManagerDidUpdateCurrentUser{
    defaultUser = [CurrentUserManager getCurrentContractUser];
    [self reloadTableView];
}

-(void) loadingStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView startAnimating];
    });
    
}
-(void) loadingStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView stopAnimating];
    });
}
-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
    
}
-(void) showAlertWithTittle:(NSString *) tittle
                 forMessage:(NSString *) message{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        alert = [UIAlertController
                 alertControllerWithTitle:tittle
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             
                                                         }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
    
}

-(void) setNavigationBarString:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.topViewController.title = str;
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
