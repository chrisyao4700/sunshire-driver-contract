//
//  ProductDetailViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/31/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductTokenHandler.h"
#import "CYContentTableViewCell.h"
#import "ProductDetailActionCollectionViewCell.h"
#import "CYContentTableViewCell.h"
#import "CYFunctionSet.h"
#import "CurrentUserManager.h"
#import "SunshireMessengerViewController.h"
#import "TripTextRootViewController.h"
#import "AppCoreDataSocket.h"
@interface ProductDetailViewController ()

@end

@implementation ProductDetailViewController{
    PRODUCT_TOKEN * token;
    NSDictionary * trip_dict;
    UIAlertController * alert;
    
    SunshireContractConnector * connector;
    UIActivityIndicatorView * loadingView;
    UIBarButtonItem * rightItem;
    
    BOOL has_receivable;
    NSNumber * is_sharing;
    
    SS_CONTRACT_USER * driver_info;
    
    NSString * alert_phone;
    
    NSInteger from_count;
    NSInteger to_count;
    
    
    SS_TRIP * core_trip;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configRightItem];
    [self setNavigationBarString:@"TRIP"];
    from_count = 0;
    to_count = 0;
    // Do any additional setup after loading the view.
}
-(void) configRightItem{
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(IBAction)rightItemDidClick:(id)sender{
    [self requestTripInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    token = [ProductTokenHandler getProductTokenWithID:self.product_id];
    [self reloadActionView];
    [self requestTripInfo];
    core_trip = [AppCoreDataSocket getTripWithID:self.product_id];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestDriverSharingStatusWithTag:3];
    if (core_trip) {
        [self reloadTripInfoView];
    }
}


-(void) requestTripInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        trip_dict = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `order_product`.`id`, `order_product`.`location_from`,`order_product`.`location_to`,`order_product`.`passenger`,`order_product`.`baggage` , `order_product`.`service_type`, `order_product`.`alert_phoneb`, `order_product`.`receivable`,`order_product`.`pickup_time`,`order_product`.`note`, `orders`.`customer_nameb` AS `passenger_name` FROM `order_product` LEFT JOIN `orders` ON `orders`.`id` = `order_product`.`order_id` WHERE `order_product`.`id` = %@ LIMIT 1",self.product_id];
        
        NSDictionary * dict = @{
                                @"query": query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1];
        
    });
}
-(void) requestAlertPhoneNumber{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        alert_phone =  nil;
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM `sunshire_info` WHERE `key` = 'phone' AND status = 1"];
        
        NSDictionary * dict = @{
                                @"query": query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:4];
        
    });
}
-(void) requestDriverSharingStatusWithTag:(NSInteger) tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        is_sharing = nil;
        
        if (!driver_info) {
            driver_info = [CurrentUserManager getCurrentContractUser];
        }
        
        NSDictionary * dict = @{
                                @"driver_id": driver_info.data_id
                                };
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        [connector sendNormalRequestWithPack:dict andServiceCode:@"check_sharing" andCustomerTag:tag];
    });
}

-(BOOL) checkreceivable{
    if (!has_receivable) {
        NSNumber * tempNum = [CYFunctionSet convertStringToNumber:[trip_dict objectForKey:@"receivable"]];
        if (tempNum.doubleValue > 0.0) {
            has_receivable = YES;
        }else{
            has_receivable = NO;
        }
    }
    
    return has_receivable;
}
#pragma table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger temp = 0;
    temp = 5;
    return temp;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (trip_dict) {
        //GET TRIP DICT
        if (section == 0) {
            //TRIP INFO
            temp = 2;
            if ([self checkreceivable] == YES) {
                temp = 3;
            }
        }
        if (section == 1 ) {
            //PICKUP LOCATION
            temp = 2;
        }
        if (section == 2) {
            //DROP-OFF LOCATION
            temp = 1;
        }
        if (section == 3) {
            //PASSENGER INFO
            temp = 1;
        }
        if (section == 4) {
            //NOTE
            if([self checkNoteValid] == YES){
                temp = 1;
            }
        }
    }else{
        //NO TRIP YET
        temp = 0;
        if (core_trip) {
            if (section == 0) {
                temp = 1;
            }
            if (section == 1) {
                temp = 2;
            }
            if (section == 2) {
                temp = 1;
            }
        }
    }
    
    
    return temp;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    
    if (section == 0) {
        temp = @"BASIC INFO";
    }
    if (section == 1) {
        
    }
    if (section == 2) {
        
    }
    
    return temp;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 60.0;
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            height = 103.00;
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            height = 103.00;
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            height = 103.00;
        }
    }
    return height;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        if (indexPath.row == 0) {
            // TRIP ID # + SERVICE TYPE
            cell.textLabel.text = [NSString stringWithFormat:@"单号# %@",[trip_dict objectForKey:@"id"]?[trip_dict objectForKey:@"id"]: core_trip.trip_id];
            cell.detailTextLabel.text = [trip_dict objectForKey:@"service_type"]?[trip_dict objectForKey:@"service_type"] : core_trip.service_type;
        }
        if (indexPath.row == 1) {
            //PASSENGER + LUGGAGE
            cell.textLabel.text = [NSString stringWithFormat:@"最大乘客人数: %@", [trip_dict objectForKey:@"passenger"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"最大行李数: %@",[trip_dict objectForKey:@"baggage"]];
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"可收现金: "];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"$ %@", [trip_dict objectForKey:@"receivable"]];
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
    if(indexPath.section == 1){
        //PICKUP INFO
        if (indexPath.row == 0) {
            //LOCATION
            CYContentTableViewCell * c_cell = (CYContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"content_cell" forIndexPath:indexPath];
            c_cell.userInteractionEnabled = YES;
            c_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            c_cell.content_title_label.text = @"出发地: ";
            c_cell.content_title_label.textColor = [UIColor whiteColor];
            c_cell.content_text_view.text = [trip_dict objectForKey:@"location_from"] ? [trip_dict objectForKey:@"location_from"] : core_trip.location_from;
            c_cell.content_text_view.editable = NO;
            
            c_cell.content_text_view.textColor = [UIColor whiteColor];
            c_cell.content_text_view.backgroundColor = [UIColor clearColor];
            return c_cell;
        }
        if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
            cell.textLabel.text = @"接客时间:";
            cell.detailTextLabel.text = [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip_dict objectForKey:@"pickup_time"]]]? [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip_dict objectForKey:@"pickup_time"]]]:[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:core_trip.pickup_time]];
        }
    }
    if(indexPath.section == 2){
        if (indexPath.row == 0) {
            CYContentTableViewCell * c_cell = (CYContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"content_cell" forIndexPath:indexPath];
            c_cell.userInteractionEnabled = YES;
            c_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            c_cell.content_title_label.text = @"目的地: ";
            c_cell.content_title_label.textColor = [UIColor whiteColor];
            c_cell.content_text_view.text = [trip_dict objectForKey:@"location_to"] ? [trip_dict objectForKey:@"location_to"] : core_trip.location_to;
            c_cell.content_text_view.editable = NO;
            
            c_cell.content_text_view.textColor = [UIColor whiteColor];
            c_cell.content_text_view.backgroundColor = [UIColor clearColor];
            return c_cell;
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
            cell.textLabel.text = @"乘客姓名:";
            cell.detailTextLabel.text = [trip_dict objectForKey:@"passenger_name"];
        }
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            CYContentTableViewCell * c_cell = (CYContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"content_cell" forIndexPath:indexPath];
            c_cell.userInteractionEnabled = NO;
            c_cell.accessoryType = UITableViewCellAccessoryNone;
            
            c_cell.content_title_label.text = @"备注: ";
            c_cell.content_title_label.textColor = [UIColor whiteColor];
            c_cell.content_text_view.text = [trip_dict objectForKey:@"note"];
            c_cell.content_text_view.editable = NO;
            
            c_cell.content_text_view.textColor = [UIColor redColor];
            c_cell.content_text_view.backgroundColor = [UIColor clearColor];
            return c_cell;
            
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //NAV TO PICKUP
            [CYFunctionSet callGoogleMapWithDestination:[trip_dict objectForKey:@"location_from"]?[trip_dict objectForKey:@"location_from"]:core_trip.location_from forCompletionHandler:^(BOOL success){
                if (success) {
                    [self reloadTripInfoView];
                }
            }
                                         forFailHandler:^{
                                             [self showAlertWithTittle:@"错误❌" forMessage:@"无法打开谷歌地图"];
                                             
                                         }];
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //NAV TO DROP-OFF
            if (to_count < 1) {
                if (token.is_sent_eta == YES) {
                    [CYFunctionSet callGoogleMapWithDestination:[trip_dict objectForKey:@"location_to"]?[trip_dict objectForKey:@"location_to"]:core_trip.location_to forCompletionHandler:^(BOOL success){
                        if (success) {
                            [self reloadTripInfoView];
                        }
                    }
                                                 forFailHandler:^{
                                                     [self showAlertWithTittle:@"错误❌" forMessage:@"无法打开谷歌地图"];
                                                     
                                                 }];
                }else{
                    [self confirmActionForTitle:@"COB WARNING" forMessage:@"您还未发送【上客】, 现在发送?" forConfirmationHandler:^(UIAlertAction * action){
                        
                        [self performActionWithKey:@"COB"];
                    }];
                }
                to_count ++;
            }else{
                [CYFunctionSet callGoogleMapWithDestination:[trip_dict objectForKey:@"location_to"]?[trip_dict objectForKey:@"location_to"]:core_trip.location_to forCompletionHandler:^(BOOL success){
                    if (success) {
                        [self reloadTripInfoView];
                    }
                }
                                             forFailHandler:^{
                                                 [self showAlertWithTittle:@"错误❌" forMessage:@"无法打开谷歌地图"];
                                                 
                                             }];
                
            }
        }
    }
}
-(void) reloadTripInfoView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tripInfoView reloadData];
    });
}


#pragma collections

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSInteger temp = 0;
    if (trip_dict) {
        temp = 2;
    }
    return temp;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        if (token) {
            temp = 4;
        }
    }
    if (section == 1) {
        temp = 5;
    }
    return temp;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ProductDetailActionCollectionViewCell * cell = (ProductDetailActionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"action_cell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 20.0;
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            if (token.is_sent_eta ==YES) {
                cell.action_title_label.text = @"【出发】\n已发";
                cell.backgroundColor = [UIColor greenColor];
            }
            if (token.is_sent_eta == NO) {
                cell.action_title_label.text = @"出发";
                cell.backgroundColor = [UIColor purpleColor];
            }
            
        }
        if (indexPath.item == 1) {
            if (token.is_sent_arrival ==YES) {
                cell.action_title_label.text = @"【到达】\n已发";
                cell.backgroundColor = [UIColor greenColor];
            }
            if (token.is_sent_arrival == NO) {
                cell.action_title_label.text = @"到达";
                cell.backgroundColor = [UIColor purpleColor];
            }
            
        }
        
        if (indexPath.item == 2) {
            if (token.is_sent_cob ==YES) {
                cell.action_title_label.text = @"【上客】\n已发";
                cell.backgroundColor = [UIColor greenColor];
            }
            if (token.is_sent_cob == NO) {
                cell.action_title_label.text = @"上客";
                cell.backgroundColor = [UIColor purpleColor];
            }
            
        }
        if (indexPath.item == 3) {
            if (token.is_sent_cad ==YES) {
                cell.action_title_label.text = @"【下客】\n已发";
                cell.backgroundColor = [UIColor greenColor];
            }
            if (token.is_sent_cad == NO) {
                cell.action_title_label.text = @"下客";
                cell.backgroundColor = [UIColor purpleColor];
            }
        }
        
    }
    if (indexPath.section == 1) {
        if (indexPath.item == 0) {
            cell.action_title_label.text = @"调度电话";
            cell.backgroundColor = [UIColor orangeColor];
        }
        if (indexPath.item == 1) {
            cell.action_title_label.text = @"紧急电话";
            cell.backgroundColor = [UIColor redColor];
        }
        if (indexPath.item == 2) {
            cell.action_title_label.text = @"发送位置";
            cell.backgroundColor = [UIColor yellowColor];
        }
        if (indexPath.item == 3) {
            cell.action_title_label.text = @"短信记录";
            cell.backgroundColor = [UIColor blueColor];
        }
        if (indexPath.item == 4) {
            cell.action_title_label.text = @"预置短信";
            cell.backgroundColor = [UIColor greenColor];
            
        }
    }
    return cell;
    
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performActionWithKey:@"ETA"];
        }
        if (indexPath.row == 1) {
            [self performActionWithKey:@"ARRIVAL"];
        }
        if (indexPath.row == 2) {
            [self performActionWithKey:@"COB"];
        }
        if (indexPath.row == 3) {
            [self performActionWithKey:@"CAD"];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.item == 0) {
            //CALL DISPATCH
            [self confirmActionForTitle:@"确定吗?" forMessage:@"您将要拨打 SUNSHIRE 调度电话" forConfirmationHandler:^(UIAlertAction * action){
                [self performCallWithNumber:[trip_dict objectForKey:@"alert_phoneb"]];
            }];
        }
        if(indexPath.item == 1){
            //CALL MANAGER
            [self confirmActionForTitle:@"确定吗?" forMessage:@"您将要拨打紧急电话" forConfirmationHandler:^(UIAlertAction * action){
                if(alert_phone && ![alert_phone isEqualToString:@""]){
                    [self performCallWithNumber:alert_phone];
                }else{
                    [self requestAlertPhoneNumber];
                }
            }];
        }
        if (indexPath.item == 2) {
            [self performActionWithKey:@"LINK"];
        }
        if (indexPath.item == 3) {
            [self performSegueWithIdentifier:@"productDetailToMessenger" sender:self];
        }
        if (indexPath.item == 4) {
            [self performSegueWithIdentifier:@"toTripTextRoot" sender:self];
        }
    }
}
-(void) performActionWithKey:(NSString *) key{
    if ([key isEqualToString:@"ETA"]) {
        if (is_sharing.boolValue == NO || !is_sharing) {
            [self requestDriverSharingStatusWithTag:2];
        }else{
            if (token.is_sent_eta == YES) {
                [self confirmActionForTitle:@"确定吗？" forMessage:@"您已经发送了【出发】，再发一次?" forConfirmationHandler:^(UIAlertAction * action){
                    //perform send ETA
                    [self performCollectETATime];
                }];
            }else{
                [self performCollectETATime];
                //perform send ETA
            }
            
        }
    }
    if ([key isEqualToString:@"ARRIVAL"]) {
        
        if (token.is_sent_arrival == YES) {
            [self showAlertWithTittle:@"警告⚠️" forMessage:@"您已经发送了【到达】，无法再次发送."];
            
        }else{
            
            [self confirmActionForTitle:@"确定吗？" forMessage:@"向客户发送【到达】并通知调度?" forConfirmationHandler:^(UIAlertAction * action){
                //perform send ARRIVAL
                [self requestActionForTag:22 forAdditionalInfo:nil];
            }];
        }
        
        
        
    }
    if ([key isEqualToString:@"COB"]) {
        if (token.is_sent_cob == YES) {
            [self showAlertWithTittle:@"错误❌" forMessage:@"您已经发送了【上客】，无法再次发送."];
            
        }else{
            
            [self confirmActionForTitle:@"确定吗？" forMessage:@"向调度发送【上客】?" forConfirmationHandler:^(UIAlertAction * action){
                //perform send COB
                [self requestActionForTag:23 forAdditionalInfo:nil];
            }];
            
        }
        
        
        
    }
    if ([key isEqualToString:@"CAD"]) {
        if ([self checkreceivable] == YES) {
            [self confirmActionForTitle:@"注意⚠️" forMessage:[NSString stringWithFormat:@"请注意收取 $ %@ 现金!",[trip_dict objectForKey:@"receivable"]] forConfirmationHandler:^(UIAlertAction *action){
                
                [self confirmActionForTitle:@"确定吗?" forMessage:@"向调度发送【下客】并结束行程?" forConfirmationHandler:^(UIAlertAction * action){
                    [self requestActionForTag:24 forAdditionalInfo:nil];
                }];
            }];
        }else{
            [self confirmActionForTitle:@"确定吗?" forMessage:@"向调度发送【下客】并结束行程?" forConfirmationHandler:^(UIAlertAction * action){
                [self requestActionForTag:24 forAdditionalInfo:nil];
            }];
        }
        
    }
    if ([key isEqualToString:@"LINK"]) {
        if (token.is_sent_eta == YES) {
            [self confirmActionForTitle:@"确定吗?" forMessage:@"您的动态位置信息已经随【出发】信息发送了, 再发一次?" forConfirmationHandler:^(UIAlertAction * action){
                [self requestActionForTag:25 forAdditionalInfo:nil];
            }];
        }else{
            [self confirmActionForTitle:@"确定吗?" forMessage:@"您的位置信息会随【出发】信息发送, 现在单独发送?" forConfirmationHandler:^(UIAlertAction * action){
                [self requestActionForTag:25 forAdditionalInfo:nil];
            }];
            
        }
        
    }
    
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
-(void) updateProductTokenWithKey:(NSString *) key{
    if ([key isEqualToString:@"ETA"]) {
        
        token.is_sent_eta = YES;
        [ProductTokenHandler saveChanges];
        [self reloadActionView];
        
    }
    if ([key isEqualToString:@"ARRIVAL"]) {
        token.is_sent_arrival = YES;
        [ProductTokenHandler saveChanges];
        [self reloadActionView];
        
        
    }
    if ([key isEqualToString:@"COB"]) {
        token.is_sent_cob = YES;
        [ProductTokenHandler saveChanges];
        [self reloadActionView];
        
        
    }
    if ([key isEqualToString:@"CAD"]) {
        
        [ProductTokenHandler removeProductTokenWithID:self.product_id];
        [self confirmActionForTitle:@"成功✌️" forMessage:@"行程结束. 请勿忘记关闭位置分享." forConfirmationHandler:^(UIAlertAction * action){
            //[self.navigationController popViewControllerAnimated:YES];
            [self performSegueWithIdentifier:@"toLocation" sender:self];
        }];
        
    }
    
    
}

-(void) reloadActionView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.actionCollectionView reloadData];
    });
}



#pragma APIS
-(void) requestActionForTag:(NSInteger) tag
          forAdditionalInfo:(NSDictionary *) addInfo{
    if (!connector) {
        connector = [[SunshireContractConnector alloc] initWithDelegate:self];
    }
    
    if (tag == 21) {
        //SEND ETA
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dict = @{
                                    @"product_id":self.product_id,
                                    @"type":@"ETA",
                                    @"mins":[addInfo objectForKey:@"mins"]
                                    };
            [connector sendNormalRequestWithPack:dict andServiceCode:@"product_service" andCustomerTag:tag];
        });
    }
    if (tag == 22) {
        //SEND ARV
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dict = @{
                                    @"product_id":self.product_id,
                                    @"type":@"ARRIVAL"
                                    
                                    };
            [connector sendNormalRequestWithPack:dict andServiceCode:@"product_service" andCustomerTag:tag];
        });
        
    }
    if (tag == 23) {
        //SEND COB
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dict = @{
                                    @"product_id":self.product_id,
                                    @"type":@"COB"
                                    };
            [connector sendNormalRequestWithPack:dict andServiceCode:@"product_service" andCustomerTag:tag];
        });
        
    }
    if (tag == 24) {
        //SEND CAD
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dict = @{
                                    @"product_id":self.product_id,
                                    @"type":@"CAD"
                                    };
            [connector sendNormalRequestWithPack:dict andServiceCode:@"product_service" andCustomerTag:tag];
        });
        
    }
    if(tag == 25){
        //SEND LINK
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary * dict = @{
                                    @"product_id":self.product_id,
                                    @"type":@"LINK"
                                    };
            [connector sendNormalRequestWithPack:dict andServiceCode:@"product_service" andCustomerTag:tag];
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

-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    [self loadingStart];
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger) tag
                         andCustomerTag:(NSInteger) c_tag{
    [self loadingStop];
    
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    
    if (![message isEqualToString:@"NO RESULT FOUND"]) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
    
}

-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        //TRIP INFO
        
        trip_dict = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        [self reloadTripInfoView];
        [self reloadActionView];
    }
    if (c_tag == 2) {
        is_sharing = (NSNumber *)[resultDic objectForKey:@"is_sharing"];
        if (is_sharing.boolValue == NO) {
            [self confirmActionForTitle:@"警告⚠️" forMessage:@"您没有分享您的位置信息, 这可能会影响这次行程的收入. 请确保开启位置分享." forConfirmationHandler:^(UIAlertAction *action){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.navigationController popViewControllerAnimated:YES];
                    [self performSegueWithIdentifier:@"toLocation" sender:self];
                });
            }];
        }
        if (is_sharing.boolValue == YES) {
            [self performCollectETATime];
        }
    }
    if (c_tag == 3) {
        is_sharing = (NSNumber *)[resultDic objectForKey:@"is_sharing"];
    }
    if (c_tag == 4) {
        NSDictionary * dict = [resultDic objectForKey:@"record"];
        alert_phone = [[CYFunctionSet stripNulls:dict] objectForKey:@"value"];
        
        [self performCallWithNumber:alert_phone];
    }
    if (c_tag == 21) {
        //SET SENT ETA
        [self updateProductTokenWithKey:@"ETA"];
        [self showAlertWithTittle:@"成功✌️" forMessage:@"【出发】已发送."];
    }
    if (c_tag == 22) {
        //SET SENT ETA
        [self updateProductTokenWithKey:@"ARRIVAL"];
        [self showAlertWithTittle:@"成功✌️" forMessage:@"【到达】已发送."];
    }
    if (c_tag == 23) {
        //SET SENT ETA
        [self updateProductTokenWithKey:@"COB"];
        [self showAlertWithTittle:@"成功✌️" forMessage:@"【上客】已发送."];
    }
    if (c_tag == 24) {
        //SET SENT ETA
        [self updateProductTokenWithKey:@"CAD"];
        //[self showAlertWithTittle:@"SUCCESS" forMessage:@"ETA SENT."];
    }
    if (c_tag == 25) {
        [self showAlertWithTittle:@"成功✌️" forMessage:[resultDic objectForKey:@"message"]];
    }
}

-(void) performCollectETATime{
    dispatch_async(dispatch_get_main_queue(), ^{
        alert = [UIAlertController
                 alertControllerWithTitle:@"预计到达时间"
                 message:@"多少分钟后到达？"
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 //[self reloadTableView];
                                                                 [self reloadActionView];
                                                             }];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             //[locationHandler updateGasPoint];
                                                             NSString * value = [[alert.textFields objectAtIndex:0] text];
                                                             
                                                             if ([self checkStringIsValidNumber:value] == YES) {
                                                                 [self requestActionForTag:21 forAdditionalInfo:@{
                                                                                                                  @"mins":value
                                                                                                                  }];
                                                             }
                                                             
                                                         }];
        
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = @"30";
        }];
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}
-(BOOL) checkStringIsValidNumber:(NSString * )value{
    BOOL flag = NO;
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([value rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        NSNumber * temp_num = [CYFunctionSet convertStringToNumber:value];
        if (temp_num.integerValue > 0) {
            flag = YES;
        }
    }
    return flag;
}
-(BOOL) checkNoteValid{
    BOOL flag = YES;
    if ([[trip_dict objectForKey:@"note"] isEqualToString:@"Empty note"]) {
        flag = NO;
    }
    if ([[trip_dict objectForKey:@"note"] isEqualToString:@"N/A"]) {
        flag = NO;
    }
    if (![trip_dict objectForKey:@"note"]) {
        flag = NO;
    }
    NSString * temp = [[trip_dict objectForKey:@"note"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([temp isEqualToString:@""]) {
        flag = NO;
    }
    return flag;
}
-(void) performCallWithNumber:(NSString *) num{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSURL *pn = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", num]];
        [[UIApplication sharedApplication] openURL:pn options:@{} completionHandler:^(BOOL success){
            [self reloadActionView];
        }];
    });
    
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"productDetailToMessenger"]) {
        SunshireMessengerViewController * smvc =(SunshireMessengerViewController *)[segue destinationViewController];
        smvc.contact_id = self.product_id;
    }
    if ([segue.identifier isEqualToString:@"toTripTextRoot"]) {
        TripTextRootViewController * ttrvc = (TripTextRootViewController *)[segue destinationViewController];
        ttrvc.tripID = self.product_id;
    }
    
}


@end
