//
//  TripTextSectionViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 7/21/17.
//  Copyright © 2017 Sunshireshuttle. All rights reserved.
//

#import "TripTextSectionViewController.h"
#import "TripTextDetailViewController.h"
#import "CurrentUserManager.h"
@interface TripTextSectionViewController ()

@end

@implementation TripTextSectionViewController{
    SunshireContractConnector * connector;
    UIAlertController * text_alert;
    
    //CurrentDispatcher * user;
    SS_CONTRACT_USER * driver_token;
    UIBarButtonItem * rightItem;
    
    NSArray * text_list;
    NSDictionary * text_pool;
    NSDictionary * section_pack;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    //user = [SunshireDispatchHandler getCurrentDispatch];
    driver_token = [CurrentUserManager getCurrentContractUser];
    connector = [[SunshireContractConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didClickRightItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    // Do any additional setup after loading the view.
}
-(IBAction)didClickRightItem:(id)sender{
    [self requestSectionDetailList];
    //[self requestSectionInfo];
    
}
-(void) requestSectionInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"table_name":@"triptext_section",
                                @"data_id":self.sectionID
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"select_solo" andCustomerTag:4];
        
    });
    
}

-(void) requestSectionDetailList{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary * dict = @{
                                @"table_name":@"triptext_detail",
                                @"condition":[NSString stringWithFormat:@"`section_id` = %@ AND `status` != 0 ",self.sectionID]
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:1];
        
    });
    
}
-(void) requestInsertTextDetailWithTitle:(NSString *) title{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = @{
                               @"table_name":@"triptext_detail",
                               @"element_array":@[
                                       @{
                                           @"key":@"title",
                                           @"value":title
                                           },
                                       @{
                                           @"key":@"section_id",
                                           @"value":self.sectionID
                                           },
                                       @{
                                           @"key":@"status",
                                           @"value":@"1"
                                           }
                                       
                                       ]
                               
                               };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"insert_record" andCustomerTag:3];
        
    });
}
-(void) requestSendTripMessage:(NSString *) msg{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        if (!driver_token) {
            driver_token = [CurrentUserManager getCurrentContractUser];
        }
        
        NSDictionary * dict =@{
                               
                               @"product_id": self.tripID,
                               @"message":msg,
                               @"cby":driver_token.data_id
                               };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"send_trip_message" andCustomerTag:5];
    });
}
-(void) requestUpdateRecordForTable:(NSString *) table_name
                          forDataID:(NSString *) data_id
                             forKey:(NSString *) key
                           forValue:(NSString *) value
                            withTag:(NSInteger) c_tag{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        NSArray * elements = @[
                               @{
                                   @"key" : key,
                                   @"value": value
                                   }
                               ];
        NSDictionary * dict = @{
                                @"table_name":table_name,
                                @"data_id":data_id,
                                @"element_array":elements
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"update_record" andCustomerTag:c_tag andWillStartBlock:^(NSInteger c_tag){
            [self loadingStart];
        } andGotResponseBlock:^(NSInteger c_tag){
            [self loadingStop];
        } andErrorBlock:^(NSInteger c_tag, NSString * message){
            [self showAlertWithTittle:@"ERROR" forMessage:message];
        } andSuccessBlock:^(NSInteger c_tag, NSDictionary * resultDict){
            //[self requestStaffInfo];
            if (c_tag == 2) {
                //[self requestClassDetailData:self.classID];
                [self requestSectionInfo];
            }
            
            if (c_tag == 11) {
                //ACTIVE
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                    
                });
                
            }
        }];
        
        
    });
}

-(void) performAlertViewTextModifyWithKey:(NSString *) key
                                 forValue:(NSString *) value
                             forTableName:(NSString *) table_name
                                forDataID:(NSString *) data_id{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        text_alert = [UIAlertController
                      alertControllerWithTitle:key
                      message:value
                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self reloadContentTable];
                                                             }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             //[locationHandler updateGasPoint];
                                                             NSString * value = [[text_alert.textFields objectAtIndex:0] text];
                                                             
                                                             if ([key isEqualToString:@"TEXT TITLE"]) {
                                                                 [self requestInsertTextDetailWithTitle:value];
                                                             }else{
                                                                 [self didSaveTextForKey:key
                                                                                andValue:value
                                                                            forTableName: table_name
                                                                               forDataID: data_id];
                                                                 
                                                             }
                                                         }];
        
        
        
        [text_alert addAction:okAction];
        [text_alert addAction:cancelAction];
        [text_alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            //textField.placeholder = @"New information here...";
            textField.text = value;
            
        }];
        [self presentViewController:text_alert animated:YES completion:nil];
    });
}
-(void) didSaveTextForKey:(NSString *) key
                 andValue:(NSString *) value
             forTableName:(NSString *) table_name
                forDataID:(NSString *) data_id{
    NSString * f_value = value;
    
    [self requestUpdateRecordForTable:table_name forDataID:data_id forKey:key forValue:f_value withTag:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestSectionDetailList];
    [self requestSectionInfo];
    
}

//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if(section == 0){
        temp = section_pack?1:0;
    }
    if (section == 1) {
        temp = 0;
    }
    if (section == 2) {
        temp = text_list?text_list.count:0;
    }
    if (section == 3) {
        temp = 0;
    }
    
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    if(section == 0){
        str = @"SECTION";
    }
    if (section == 2) {
        str= @"PRE-SET TEXTS";
    }
    if (section == 3) {
        //str= @" ";
    }
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"SECTION TITLE";
            cell.detailTextLabel.text = [section_pack objectForKey:@"title"];
            cell.userInteractionEnabled = NO;
        }
    }
    
    if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ADD NEW TEXT";
            cell.detailTextLabel.text = @"";
        }
    }
    if(indexPath.section == 2){
        
        text_pool = [CYFunctionSet stripNulls:[text_list objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"TEXT # %@",[text_pool objectForKey:@"id"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [text_pool objectForKey:@"title"]];
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"DELETE SECTION";
            cell.detailTextLabel.text = @"";
            cell.backgroundColor = [UIColor redColor];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"title" forValue:[section_pack objectForKey:@"title"] forTableName:@"triptext_section" forDataID:self.sectionID];
        }
    }
    
    if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"TEXT TITLE" forValue:@"" forTableName:@"" forDataID:@""];
            
        }
    }
    if (indexPath.section == 2) {
        text_pool = [CYFunctionSet stripNulls:[text_list objectAtIndex:indexPath.row]];
        [self performSegueWithIdentifier:@"toPreview" sender:self];
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self confirmActionForTitle:@"ARE YOU SURE" forMessage:@"DELETE ENTIRE SECTION?" forConfirmationHandler:^(UIAlertAction * action){
                [self requestUpdateRecordForTable:@"triptext_section" forDataID:self.sectionID forKey:@"status" forValue:@"0" withTag:11];
                
            }];
        }
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];
        headerView.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(void)dataSocketWillStartRequestWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStart];
}
-(void)dataSocketDidGetResponseWithTag:(NSInteger)tag andCustomerTag:(NSInteger)c_tag{
    [self loadingStop];
}

-(void)dataSocketErrorWithTag:(NSInteger)tag andMessage:(NSString *)message andCustomerTag:(NSInteger)c_tag{
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
    [self reloadContentTable];
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1){
        text_list = [resultDic objectForKey:@"records"];
    }
    if (c_tag == 3){
        text_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(),^{
            [self performSegueWithIdentifier:@"toPreview" sender:self];
        });
        
    }
    if (c_tag == 4) {
        section_pack = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
    }
    if (c_tag ==  5) {
        [self confirmActionForTitle:@"成功✌️" forMessage:@"信息发送成功！" forConfirmationHandler:^(UIAlertAction * action){
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    
    if (section_pack) {
        [self reloadContentTable];
    }
}

-(void) reloadContentTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadData];
    });
}
-(void) reloadContentTableWithIndexPath:(NSIndexPath *)indexPath{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    });
}

-(void)tripTextPreviewDidCancel{
    [self reloadContentTable];
}
-(void)tripTextPreviewDidSendText:(NSString *)text{
    [self requestSendTripMessage:text];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toPreview"]) {
        TripTextPreviewViewController * ttpvc = (TripTextPreviewViewController *)[segue destinationViewController];
        ttpvc.delegate = self;
        ttpvc.textContent = [text_pool objectForKey:@"content"];
    }
}
@end
