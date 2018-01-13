//
//  TripTextRootViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 7/21/17.
//  Copyright © 2017 Sunshireshuttle. All rights reserved.
//

#import "TripTextRootViewController.h"


@interface TripTextRootViewController ()

@end

@implementation TripTextRootViewController{
    SunshireContractConnector * connector;
    UIAlertController * text_alert;
    
    //CurrentDispatcher * user;
    
    UIBarButtonItem * rightItem;
    
    
    NSArray * section_list;
    NSDictionary * section_pool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configBackgroundView];
    //user = [SunshireDispatchHandler getCurrentDispatch];
    connector = [[SunshireContractConnector alloc] initWithDelegate:self];
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didClickRightItem:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    // Do any additional setup after loading the view.
}
-(IBAction)didClickRightItem:(id)sender{
    [self requestSectionList];
}

-(void) requestSectionList{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = @{
                               @"table_name":@"triptext_section",
                               @"condition":@"`status` != 0"
                               
                               };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"search_array" andCustomerTag:1];
    
    });
}
-(void) requestInsertSectionWithTitle:(NSString *) title{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = @{
                               @"table_name":@"triptext_section",
                               @"element_array":@[
                                       @{
                                           @"key":@"title",
                                           @"value":title
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
                                                             [self requestInsertSectionWithTitle:value];                                                        }];
        
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
    [self requestSectionList];
    
}

//TABLE FUNCTIONS
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 0;
    }
    if (section == 1) {
        temp = section_list?section_list.count:0;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * str = @"";
    if (section == 0) {
        str= @"";
    }
    if (section == 1) {
        str=@"SECTIONS";
    }
    
    return str;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        // ADD
        if (indexPath.row ==0) {
            cell.textLabel.text = @"ADD NEW SECTION";
            cell.detailTextLabel.text = @"";
        }
        
    }
    
    if (indexPath.section == 1) {
        section_pool = [CYFunctionSet stripNulls:[section_list objectAtIndex:indexPath.row]];
        cell.textLabel.text = [NSString stringWithFormat:@"SECTION # %@",[ section_pool objectForKey:@"id"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[section_pool objectForKey:@"title"]];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performAlertViewTextModifyWithKey:@"NEW SECTION TITLE" forValue:@"" forTableName:@"" forDataID:@""];
        }
    }
    if (indexPath.section == 1) {
        section_pool = [CYFunctionSet stripNulls:[section_list objectAtIndex:indexPath.row]];
        [self performSegueWithIdentifier:@"toSectionDetail" sender:self];
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
    if (c_tag == 1 ) {
        section_list = [resultDic objectForKey:@"records"];
        [self reloadContentTable];
    }
    if (c_tag == 3) {
        //[self requestSectionList];
        section_pool = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"toSectionDetail" sender:self];
        });
        
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
-(void)tripTextSectionDidSendMessage{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"toSectionDetail"]) {
        TripTextSectionViewController * ttxvc = (TripTextSectionViewController *)[segue destinationViewController];
        ttxvc.sectionID = [section_pool objectForKey:@"id"];
        ttxvc.tripID = self.tripID;
        ttxvc.delegate  = self;
    }
}
@end
