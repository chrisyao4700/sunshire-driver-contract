//
//  NoloadDetailViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 6/5/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "NoloadDetailViewController.h"
#import "CYFunctionSet.h"
#import "CurrentUserManager.h"
@interface NoloadDetailViewController ()

@end

@implementation NoloadDetailViewController{
    UIActivityIndicatorView * loadingView;
    UIAlertController * alert;
    
    
    NSDictionary * noloadInfo;
    
    SunshireContractConnector * connector;
    
    
    SS_CONTRACT_USER * currentUser;
    
    UIBarButtonItem * rightItem;
    
    DateTimeSelectorViewController * dpvc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    [self configLoadingView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.noload_id) {
        [self requestNoloadInfo];
    }else{
        [self requestInserNoloadInfo];
    }
}
-(void) configRightItem{
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(rightItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(IBAction)rightItemDidClick:(id)sender{
    [self confirmActionForTitle:@"警告⚠️" forMessage:@"确定发布空车信息吗?" forConfirmationHandler:^(UIAlertAction * action){
        [self requestActiveNoloadInfo];
    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (noloadInfo) {
        if (section == 0) {
            temp = 4;
        }
        if (section == 1) {
            temp = 1;
        }
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"行程讯息";
    }
    if (section == 1) {
        temp = @" ";
    }
    return temp;
}
-(void) requestNoloadInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        NSString * query = [NSString stringWithFormat:@"SELECT `noload_info`.*, `noload_info_status`.`info_status` AS `status_str` FROM `noload_info` LEFT JOIN `noload_info_status` ON `noload_info_status`.`id` = `noload_info`.`status` WHERE `noload_info`.`id` = %@",self.noload_id];
        NSDictionary * dict = @{
                                @"query":query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1];

    });
}
-(void) requestInserNoloadInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        if(!currentUser){
            currentUser = [CurrentUserManager getCurrentContractUser];
        }
        
        NSDictionary * dict = @{
                                @"driver_id" : currentUser.data_id,
                                @"location_from": @"",
                                @"location_to": @"",
                                @"trip_date": [CYFunctionSet convertDateToString:[NSDate date]]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"post_noload" andCustomerTag:2];
    });
}
-(void) requestUpdateNoloadInfoStatus:(NSString *) status_index{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        NSString * query = [NSString stringWithFormat:@"UPDATE `noload_info` SET `status` = %@ WHERE `id` = %@ ",status_index,self.noload_id];
        
        NSDictionary * dict = @{
                                @"query": query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_update" andCustomerTag:3];
    });
    
    
}

-(void) requestUpdateNoloadInfoWithKey:(NSString *) key
                              forValue:(NSString *) value{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        NSString * query = [NSString stringWithFormat:@"UPDATE `noload_info` SET `%@` = '%@' WHERE `id` = %@ ",key,value,self.noload_id];
        
        NSDictionary * dict = @{
                                @"query": query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_update" andCustomerTag:4];
    });
    
    
}


-(void) requestActiveNoloadInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        NSDictionary * dict = @{
                                @"id":self.noload_id
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"active_noload" andCustomerTag:5];

    });
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 70.0;
    return height;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"行程号 #: %@", self.noload_id];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[noloadInfo objectForKey:@"status_str"]];
            cell.userInteractionEnabled = NO;
        }
        if (indexPath.row == 1) {
            //FROM
            cell.textLabel.text = [NSString stringWithFormat:@"出发地:"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [noloadInfo objectForKey:@"location_from"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 2) {
            //TO
            cell.textLabel.text = [NSString stringWithFormat:@"目的地:"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [noloadInfo objectForKey:@"location_to"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 3) {
            //TRIP DATE
            cell.textLabel.text = [NSString stringWithFormat:@"行程时间:"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[noloadInfo objectForKey:@"trip_date"]]]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    if (indexPath.section == 1) {
        //ACTIONS
        if (indexPath.row == 0) {
            //DELETE
            //[self requestUpdateNoloadInfoStatus:@"0"];
            cell.textLabel.text = @"删除";
            cell.detailTextLabel.text =  @" ";
            cell.backgroundColor = [UIColor redColor];
            
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //NORMAL ATTRIBUTES
        if (indexPath.row == 1) {
            //FROM
            [self performAlertViewTextModifyWithKey:@"location_from" forValue:[noloadInfo objectForKey:@"location_from"] forCustomerTag:0];
        }
        if (indexPath.row == 2) {
            //TO
            [self performAlertViewTextModifyWithKey:@"location_to" forValue:[noloadInfo objectForKey:@"location_to"] forCustomerTag:0];
        }
        if (indexPath.row == 3) {
            //TRIP DATE
            [self performDateTimeSelectorWithKey:@"trip_date" forOrgDate:[CYFunctionSet convertStringToDate:[noloadInfo objectForKey:@"trip_date"]]];
        }
    }
    if (indexPath.section== 1) {
        if (indexPath.row == 0) {
            //DELETE
            
            [self confirmActionForTitle:@"警告⚠️" forMessage:@"确定删除空车信息吗？" forConfirmationHandler:^(UIAlertAction * action){
                [self requestUpdateNoloadInfoStatus:@"0"];
            }];
            
        }
    }
}

#pragma text edit
-(void) performAlertViewTextModifyWithKey:(NSString *) key
                                 forValue:(NSString *) value
                           forCustomerTag:(NSInteger) c_tag{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        alert = [UIAlertController
                 alertControllerWithTitle:key
                 message:value
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //[self reloadTableView];
                                                                 [self reloadContentView];
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
            textField.placeholder = @"CONTENT HERE!";
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
    [self requestUpdateNoloadInfoWithKey:key forValue:value];
}
#pragma datepick

-(void) performDateTimeSelectorWithKey:(NSString *)key
                            forOrgDate:(NSDate *) aDate{
    if (!dpvc) {
        dpvc = [[DateTimeSelectorViewController alloc] init];
    }
    dpvc.delegate = self;
    dpvc.key = key;
    dpvc.org_date = aDate;
    
    [self presentViewController:dpvc animated:YES completion:nil];
}
-(void)datetimePickerDidCancelWithKey:(NSString *)key{
    [self reloadContentView];
}
-(void) datetimePickerDidSaveWithKey:(NSString *)key andValue:(NSString *)selectedDate{
    [self requestUpdateNoloadInfoWithKey:key forValue:selectedDate];
}

#pragma datasocket

-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    [self loadingStart];
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger)tag
                         andCustomerTag:(NSInteger) c_tag{
    [self loadingStop];
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"错误❌" forMessage:message];
    }
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        //Request Whole info
        noloadInfo = [resultDic objectForKey:@"record"];
        [self reloadContentView];
    }
    if (c_tag == 2) {
        //Insert new
        self.noload_id = [resultDic objectForKey:@"id"];
        [self requestNoloadInfo];
    }
    if (c_tag == 3) {
        //Update Status
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    if (c_tag == 4) {
        //UPDATE NORMAL ATTIBUTES
        [self requestNoloadInfo];
    }
    if (c_tag == 5) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

#pragma loading and alert

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
-(void) confirmActionForTitle:(NSString *) title
                   forMessage:(NSString *) message
       forConfirmationHandler: (void (^)(UIAlertAction * action)) handler {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        alert = [UIAlertController
                 alertControllerWithTitle:title
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:handler];
        [alert addAction:okAction];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
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

-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
}
-(void) setNavigationBarString:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.topViewController.title = str;
    });
}
-(void) reloadContentView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.noloadView reloadData];
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
