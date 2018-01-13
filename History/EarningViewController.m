//
//  EarningViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/23/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "EarningViewController.h"
#import "CurrentUserManager.h"
#import "CYFunctionSet.h"
#import "TripDetailViewController.h"
@interface EarningViewController ()

@end

@implementation EarningViewController{
    UIActivityIndicatorView * loadingView;
    UIAlertController * alert;
    
    
    NSDate * from_date;
    NSDate * to_date;
    
    SunshireContractConnector * connector;
    SS_CONTRACT_USER * contract_driver;
    
    
    NSArray * trip_list;
    
    
    NSDictionary * trip_pool;
    
    DatePickerViewController * dpvc;
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configSearchDate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) configSearchDate{
    if (!to_date) {
        to_date = [NSDate date];
    }
    if (!from_date) {
        from_date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*30*(-1)];
    }
    //[self reloadTableView];
    [self requestEearningData];
}

-(void) requestEearningData{
    dispatch_async(dispatch_get_main_queue(), ^{
        contract_driver = [CurrentUserManager getCurrentContractUser];
        trip_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `trip_history`.`idtrip_history`, `trip_history`.`start_time`,`trip_history`.`end_time`,`trip_history`.`mile_age`, `trip_history`.`time_consumed`, `trip_history_status`.`status` AS `status_str` FROM `trip_history` LEFT JOIN `trip_history_status` ON `trip_history`.`status` = `trip_history_status`.`id` WHERE DATE(`trip_history`.`start_time`) > '%@' AND DATE(`trip_history`.`end_time`) < '%@' AND `trip_history`.`driver_id` = '%@' AND `trip_history`.`status` != 0 ",[CYFunctionSet convertDateToYearString:from_date],[CYFunctionSet convertDateToYearString:to_date], contract_driver.data_id];
        
        NSDictionary * dict = @{
                                @"query" : query
                                };
        
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}

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
        //trip_list = nil;
        [self showAlertWithTittle:@"ERROR" forMessage:message];
    }
    
    [self reloadTableView];
    
}

-(void) datasocketDidReceiveNormalResponseWithDict:(NSDictionary *) resultDic
                                    andCustomerTag:(NSInteger) c_tag{
    if (c_tag == 1) {
        trip_list = [resultDic objectForKey:@"records"];
        [self reloadTableView];
    }
}
#pragma mark loading
-(void) reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.earningTable reloadData];
    });
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


#pragma mark table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger temp = 0;
    if (to_date && from_date) {
        temp = 1;
        if (trip_list) {
            temp ++;
        }
    }
    return temp;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = 3;
    }
    if (section == 1) {
        temp = trip_list.count;
    }
    return temp;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        temp = @"DATE";
    }
    if (section == 1) {
        temp = @"TRIPS";
    }
    return temp;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    if (indexPath.section == 0) {
        // SEARCH CONDITIONS
        if (indexPath.row == 0) {
            //FROM DATE
            cell.textLabel.text = @"FROM";
            cell.detailTextLabel.text = [CYFunctionSet convertDateToYearString:from_date];
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"TO";
            cell.detailTextLabel.text = [CYFunctionSet convertDateToYearString:to_date];
        }
        if (indexPath.row == 2) {
            cell.textLabel.text= @"SEARCH";
            cell.detailTextLabel.text = @"";
        }
    }
    if (indexPath.section == 1) {
        trip_pool = [CYFunctionSet stripNulls:[trip_list objectAtIndex:indexPath.row]];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ --- %@",[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip_pool objectForKey:@"start_time"]]],[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip_pool objectForKey:@"end_time"]]]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[trip_pool objectForKey:@"status_str"]];
    }
    return cell;
    
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //FROM
            [self performDatePickeWithKey:@"FROM" forOrgDate:from_date];
        }
        if (indexPath.row == 1) {
            //TO
            [self performDatePickeWithKey:@"TO" forOrgDate:to_date];
        }
        if (indexPath.row == 2) {
            [self requestEearningData];
        }
    }
    if (indexPath.section == 1) {
        // TRIP
        trip_pool = [trip_list objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"earningToTripDetail" sender:self];
    }
}


#pragma mark Date Picker
-(void) performDatePickeWithKey:(NSString *) key
                     forOrgDate:(NSDate *) org_date{
    if (!dpvc) {
        dpvc = [[DatePickerViewController alloc]init];
        
    }
    
    if (dpvc) {
        dpvc.delegate = self;
        dpvc.key= key;
        dpvc.org_date = org_date;
        
        [self showDetailViewController:dpvc sender:self];
    }else{
        [self showAlertWithTittle:@"ERROR" forMessage:@"CANNOT INIT DATE PICKER"];
    }
    
}
-(void)datePickerDidClickCancel{
    [self reloadTableView];
}
-(void)datePickerDidSaveDate:(NSDate *)aDate forKey:(NSString *)key{
    if ([key isEqualToString:@"TO"]) {
        to_date = aDate;
    }
    if ([key isEqualToString:@"FROM"]) {
        from_date = aDate;
    }
    [self reloadTableView];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"earningToTripDetail"]) {
        TripDetailViewController * tdvc = [segue destinationViewController];
        tdvc.trip_history_id = [trip_pool objectForKey:@"idtrip_history"];
    }
}


@end
