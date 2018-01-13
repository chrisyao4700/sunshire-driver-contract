//
//  ProductRootViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/30/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ProductRootViewController.h"
#import "CurrentUserManager.h"
#import "ProductRootTableViewCell.h"
#import "CYFunctionSet.h"
#import "CYColorSet.h"
#import "ProductDetailViewController.h"
#import "NoLoadRootTableViewCell.h"
#import "NoloadDetailViewController.h"
@interface ProductRootViewController ()

@end

@implementation ProductRootViewController{
    UIAlertController * alert;
    UIActivityIndicatorView * loadingView;
    
    
    SunshireContractConnector * connector;
    
    SS_CONTRACT_USER * current_user;
    
    
    NSArray * product_list;
    NSArray * noload_list;
    
    NSDictionary * noload_pool;
    NSDictionary * product_pool;
    UIBarButtonItem * rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configRightItem];
    
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestProductList];
    [self requestNoloadList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) configRightItem{
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightItemDidClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(IBAction)rightItemDidClick:(id)sender{
    [self requestProductList];
    [self requestNoloadList];
}

#pragma requests
-(void) requestProductList{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        if (!current_user) {
            current_user = [CurrentUserManager getCurrentContractUser];
        }
        product_list = nil;
        NSString * query = [NSString stringWithFormat:@"SELECT `order_product`.`id`, `order_product`.`location_from`,`order_product`.`location_to`,`order_product`.`pickup_time`,`order_product`.`service_type`,`order_product`.`status`,`order_product_status`.`name` AS `status_str` FROM `order_product` LEFT JOIN `order_product_status` ON `order_product_status`.`id` = `order_product`.`status` WHERE `driver_id`= %@ AND `order_product`.`status` IN (2,3,4,5,7) ORDER BY `pickup_time` ASC", current_user.data_id];
        
        NSDictionary * dict = @{
                                @"query" :query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:1];
    });
}
-(void) requestNoloadList{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if(!connector){
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        if (!current_user) {
            current_user = [CurrentUserManager getCurrentContractUser];
        }
        noload_list = nil;

        
        NSString * query = [NSString stringWithFormat:@"SELECT `noload_info`.*, `noload_info_status`.`info_status` AS `status_str` FROM `noload_info` LEFT JOIN `noload_info_status` ON `noload_info_status`.`id` = `noload_info`.`status` WHERE `noload_info`.`driver_id` = '%@' AND `noload_info`.`status` != 0 AND `noload_info`.`trip_date` > '%@'", current_user.data_id , [CYFunctionSet convertDateToFormatString:[NSDate date]]];
        
        NSDictionary * dict = @{
                                @"query" : query
                                };
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
    
    
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
        [self showAlertWithTittle:@"错误❌" forMessage:message];
    }else{
        [self reloadContetView];
    }
    
}

-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        product_list = [resultDic objectForKey:@"records"];
        [self reloadContetView];
    }
    if (c_tag == 2) {
        noload_list = [resultDic objectForKey:@"records"];
        [self reloadContetView];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

   
    NSInteger temp;
    
    temp = 3;
    
    return temp;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 142.00;
    
    if (indexPath.section == 1) {
        height = 88.00;
    }
    return height;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * temp = @"";
    if (section == 0) {
        // PRODUCT
        if (product_list.count > 0) {
             temp = @"行程";
        }
    }
    if (section == 1) {
        temp = @"我的空车信息";
    }
    if (section == 2) {
        temp= @"已发布的空车信息";
    }
    return temp;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger temp = 0;
    if (section == 0) {
        temp = product_list.count;
    }
    if (section == 1) {
        temp = 1;
    }
    if (section == 2) {
        temp = noload_list.count;
    }
    return temp;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * d_cell;
    if (indexPath.section == 0) {
        ProductRootTableViewCell * cell = (ProductRootTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        product_pool = [CYFunctionSet stripNulls:[product_list objectAtIndex:indexPath.row]];
        
        cell.product_id_label.text = [NSString stringWithFormat:@"单号 # %@",[product_pool objectForKey:@"id"]];
        cell.status_label.text = [NSString stringWithFormat:@"%@",[product_pool objectForKey:@"status_str"]];
        cell.service_type_label.text = [NSString stringWithFormat:@"%@",[product_pool objectForKey:@"service_type"]];
        cell.from_address_label.text = [NSString stringWithFormat:@"%@", [product_pool objectForKey:@"location_from"]];
        cell.to_address_label.text = [NSString stringWithFormat:@"%@", [product_pool objectForKey:@"location_to"]];
        cell.pickuptime_label.text = [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[product_pool objectForKey:@"pickup_time"]]];
        return cell;
    }
    if (indexPath.section == 1) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"add_cell" forIndexPath:indexPath];

        cell.textLabel.text = @"发布空车信息";
        cell.detailTextLabel.text = @"帮助我们提高您的接单效率";
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    if (indexPath.section == 2) {
        NoLoadRootTableViewCell * cell = (NoLoadRootTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"noload_cell" forIndexPath:indexPath];
        noload_pool = [CYFunctionSet stripNulls:[noload_list objectAtIndex:indexPath.row]];
        cell.from_label.text = [NSString stringWithFormat:@"出发地: %@", [noload_pool objectForKey:@"location_from"]];
        cell.to_label.text = [NSString stringWithFormat:@"目的地: %@", [noload_pool objectForKey:@"location_to"]];
        cell.trip_time_label.text = [NSString stringWithFormat:@"时间: %@ - 状态: %@",[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[noload_pool objectForKey:@"trip_date"]]], [noload_pool objectForKey:@"status_str"]];

        return cell;
    }
    return d_cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        product_pool = [CYFunctionSet stripNulls:[product_list objectAtIndex:indexPath.row]];
        [self performSegueWithIdentifier:@"productRootToProductDetail" sender:self];
    }
    if (indexPath.section == 1) {
        noload_pool = nil;
        [self performSegueWithIdentifier:@"productRootToNoloadDetail" sender:self];
    }
    if (indexPath.section == 2) {
        noload_pool = [noload_list objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"productRootToNoloadDetail" sender:self];
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
-(void) reloadContetView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.productTable reloadData];
    });
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"productRootToProductDetail"]) {
        ProductDetailViewController * pdvc = (ProductDetailViewController *)[segue destinationViewController];
        pdvc.product_id = [product_pool objectForKey:@"id"];
    }
    if ([segue.identifier isEqualToString:@"productRootToNoloadDetail"]) {
        if (noload_pool) {
            NSString * noload_id = [noload_pool objectForKey:@"id"];
            NoloadDetailViewController * ndvc = (NoloadDetailViewController *)[segue destinationViewController];
            ndvc.noload_id = noload_id;
            
        }
    }
}


@end
