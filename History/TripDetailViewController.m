//
//  TripDetailViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 7/18/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import "TripDetailViewController.h"
#import "CYFunctionSet.h"



@interface TripDetailViewController ()

@end

@implementation TripDetailViewController{
    NSTimer * topTitleTimer;
    UIAlertController * alert;
    UIActivityIndicatorView * loadingView;
   
    
    NSArray * trip_nodes;
    NSDictionary * trip;
    
    NSDictionary * node_pool;
    SunshireContractConnector * connector;
    
    NSNumber * latitude_pool;
    NSNumber * longitude_pool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self requestTripInfo];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) requestTripInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        
        NSString * query = [NSString stringWithFormat:@"SELECT `trip_history`.`start_time`,`trip_history`.`end_time`,`trip_history`.`trip_id`, `trip_history`.`payment_total`, `trip_history`.`is_paid`,`trip_history_status`.`status` AS `status_str`, `trip_history`.`time_consumed`,`trip_history`.`mile_age` FROM `trip_history` LEFT JOIN `trip_history_status` ON `trip_history`.`status` = `trip_history_status`.`id` WHERE `idtrip_history` = %@",
                            self.trip_history_id];
        
        NSDictionary * dict = @{
                    @"query":query
        };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_solo" andCustomerTag:1];
    
    });
}
-(void) requestLocationInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        
        NSString * query = [NSString stringWithFormat:@"SELECT * FROM `location_history` WHERE `trip_id` = %@ ORDER BY `reg_date` ASC", [trip objectForKey:@"trip_id"]];
        
        NSDictionary * dict = @{
                                @"query":query
                                };
        
        [connector sendNormalRequestWithPack:dict andServiceCode:@"special_array" andCustomerTag:2];
        
    });
}



-(void) drawLinesAndPinToMap{
    dispatch_async(dispatch_get_main_queue(), ^{
        CLLocationCoordinate2D coordinateArray[trip_nodes.count];
        
        for (int i = 0; i<trip_nodes.count; i++) {
            node_pool = [trip_nodes objectAtIndex:i];
            latitude_pool = [CYFunctionSet convertStringToNumber:[node_pool objectForKey:@"latitude"]];
            longitude_pool = [CYFunctionSet convertStringToNumber:[node_pool objectForKey:@"longitude"]];
            coordinateArray[i] = CLLocationCoordinate2DMake(latitude_pool.doubleValue,longitude_pool.doubleValue);
            
            

            
            
            if ([[node_pool objectForKey:@"action"] isEqualToString:@"8"]) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = @"APP OFF";
                [annotation setCoordinate:CLLocationCoordinate2DMake(latitude_pool.doubleValue, longitude_pool.doubleValue)];
                [annotation setSubtitle:[NSString stringWithFormat:@"Time: %@", [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[node_pool objectForKey:@"reg_date"]]]]];
                [self.tripMap addAnnotation:annotation];
                //[self createLineToMapWithCurrentNode:node forLastNode:last_node];
                
                
            }
            
            
            if ([[node_pool objectForKey:@"action"] isEqualToString:@"1"]) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = @"START";
                [annotation setCoordinate:CLLocationCoordinate2DMake(latitude_pool.doubleValue, longitude_pool.doubleValue)];
                [annotation setSubtitle:[NSString stringWithFormat:@"Time: %@", [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[node_pool objectForKey:@"reg_date"]]]]];
                [self.tripMap addAnnotation:annotation];
                //[self createLineToMapWithCurrentNode:node forLastNode:last_node];
                
                
            }

            
            
            if ([[node_pool objectForKey:@"action"] isEqualToString:@"9"]) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = @"END";
                [annotation setCoordinate:CLLocationCoordinate2DMake(latitude_pool.doubleValue, longitude_pool.doubleValue)];
                [annotation setSubtitle:[NSString stringWithFormat:@"Time: %@", [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[node_pool objectForKey:@"reg_date"]]]]];
                [self.tripMap addAnnotation:annotation];
                //[self createLineToMapWithCurrentNode:node forLastNode:last_node];
                
                MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
                
                region.center.latitude = latitude_pool.doubleValue;
                region.center.longitude = longitude_pool.doubleValue;
                region.span.longitudeDelta = 0.2f;
                region.span.latitudeDelta = 0.2f;
                [self.tripMap setRegion:region animated:YES];
            }

        }
        
        [self.tripMap addOverlay:[MKPolyline polylineWithCoordinates:coordinateArray count:trip_nodes.count]];
    
    });
    
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    lineView.lineWidth = 7;
    if([overlay isKindOfClass:[MKPolyline class]]){
        lineView.lineWidth = 7;
        lineView.strokeColor = [UIColor blueColor];
    }
    return lineView;
}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    MKPinAnnotationView * pinView;
    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapPinAnnotationView"];
    pinView.canShowCallout = YES;
    
    if ([annotation.title isEqualToString:@"START"]) {
        pinView.pinTintColor = [UIColor greenColor];
    }
    if ([annotation.title isEqualToString:@"STAY"]) {
        pinView.pinTintColor = [UIColor yellowColor];
    }
    if ([annotation.title isEqualToString:@"App off"]) {
        pinView.pinTintColor = [UIColor orangeColor];
    }
    if ([annotation.title isEqualToString:@"END"]) {
        pinView.pinTintColor = [UIColor redColor];
    }
    
    pinView.calloutOffset = CGPointMake(0, 0);
    pinView.annotation = annotation;
    
    [pinView setSelected:YES];
    
    return pinView;
    
    
}

-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    [self loadingStart];
    [self setTopBarTitle:@"CONNECTING..."];
    
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger)tag
                         andCustomerTag:(NSInteger) c_tag{
    [self loadingStop];
    
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    [self showAlertWithTittle:@"ERROR" forMessage:message];
    [self reloadTableView];
    [self updateTitle];
    
}

-(void) datasocketDidReceiveNormalResponseWithDict:(NSDictionary *) resultDic
                                    andCustomerTag:(NSInteger) c_tag{
    if (c_tag == 1) {
        //TRIP INFO
        trip = [CYFunctionSet stripNulls:[resultDic objectForKey:@"record"]];
        if (trip) {
            [self requestLocationInfo];
        }
        [self reloadInfoView];
    }
    if (c_tag == 2) {
        trip_nodes = [resultDic objectForKey:@"records"];
        [self drawLinesAndPinToMap];
    }
    
    [self updateTitle];
}




#pragma mark TABLE VIEW
-(void) reloadTableView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoTable reloadData];
    });
}

/*-------------------------------*
 *
 * Loading View & Alert roots
 *
 -------------------------------*/


-(void) reloadInfoView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.infoTable reloadData];
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
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
    
}

-(void) setTopbarTittle:(NSString *) tempStr{
    self.navigationController.topViewController.title = tempStr;
}

#pragma mark table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"TRIP # %@",[trip objectForKey:@"trip_id"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[trip objectForKey:@"status_str"]];
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ -- %@", [CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip objectForKey:@"start_time"]]],[CYFunctionSet convertDateToShortStr:[CYFunctionSet convertStringToDate:[trip objectForKey:@"end_time"]]]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ mins",[trip objectForKey:@"time_consumed"]];
    }
    if(indexPath.row == 2){
        cell.textLabel.text =[NSString stringWithFormat:@"%.2f miles",[[CYFunctionSet convertStringToNumber:[trip objectForKey:@"mile_age"]] doubleValue]];
        cell.detailTextLabel.text =[NSString stringWithFormat:@"$ %.2f",[[CYFunctionSet convertStringToNumber:[trip objectForKey:@"total_payment"]] doubleValue]];[NSString stringWithFormat:@"%@", [trip objectForKey:@"status_str"]];
        
    }
    if (indexPath.row == 3) {
        cell.textLabel.text = @"VIEW TRIP LOG";
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}
/*collection */
/*
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return productList.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ProductPreviewCollectionViewCell * cell = (ProductPreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"productCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.userInteractionEnabled = NO;
    productPool = [productList objectAtIndex:indexPath.item];
    cell.productIDLabel.text = [productPool objectForKey:@"id"];
    cell.etaAlertLabel.text = [NSString stringWithFormat:@"Time Sent ETA: %@",[productPool objectForKey:@"eta_alert"]];
    cell.pickuptimeLabel.text = [NSString stringWithFormat:@"Time Sent ARV: %@",[productPool objectForKey:@"arrival_datetime"]];
    cell.cadTimeLabel.text = [NSString stringWithFormat:@"Time Sent CAD: %@",[productPool objectForKey:@"cad_datetime"]];
    cell.locationFromLabel.text = [NSString stringWithFormat:@"From: %@",[productPool objectForKey:@"location_from"]];
    cell.locationToLabel.text = [NSString stringWithFormat:@"To: %@",[productPool objectForKey:@"location_to"]];
    NSNumber* has_alert = (NSNumber *) [[productPool objectForKey:@"alert_data"] objectForKey:@"status"];
    if (has_alert.boolValue == YES) {
        cell.backgroundColor = [UIColor redColor];
        cell.userInteractionEnabled = YES;
    }
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    productPool = [productList objectAtIndex:indexPath.item];
    [self performSegueWithIdentifier:@"tripDetailToAlertLog" sender:self];
}
 */

/*-----------------------------
 *
 * End of Loading & Alert
 *
 -------------------------------*/


/* Delegates */
/*
-(void)performDatetimeChangeForKey:(NSString *) key
                        forOrgDate:(NSDate *) orgDate{
    if (!dtsvc) {
        dtsvc =[[DateTimeSelectorViewController alloc] init];
    }
    dtsvc.delegate = self;
    dtsvc.key = key;
    dtsvc.org_date = orgDate;
    
    [self showDetailViewController:dtsvc sender:self];
    
}
-(void) datetimePickerDidSaveWithKey:(NSString *)key andValue:(NSString *)selectedDate{
    [tripHistoryHandler sendRequestForUpdateTripWithID:self.trip.tripId forKey:key forValue:selectedDate];
}
-(void)datetimePickerDidCancelWithKey:(NSString *)key{
    [self reloadInfoView];
}
-(void) performTextEditForKey:(NSString *) key
                     forValue:(NSString *) value{
    if (!tevc) {
        tevc = [[TextEditorViewController alloc] init];
    }
    tevc.delegate = self;
    tevc.key = key;
    tevc.orgValue = value;
    
    [self showDetailViewController:tevc sender:self];
}
-(void)didSaveTextForKey:(NSString *)key andText:(NSString *)value{
    
    [tripHistoryHandler sendRequestForUpdateTripWithID:self.trip.tripId forKey:key forValue:value];
}
-(void)didCancelTextSelectingForKey:(NSString *)key{
    [self reloadInfoView];
}
 */
/*Title views */

-(void) updateTitle{
    dispatch_async(dispatch_get_main_queue(), ^{
        topTitleTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                         target:self
                                                       selector:@selector(timerDidFire:)
                                                       userInfo:nil
                                                        repeats:NO];
    });
}
-(void) setDefaultTopBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setTopBarTitle:@"TRIP DETAIL"];
    });
}
- (void) timerDidFire:(NSTimer *)timer{
    [self setDefaultTopBar];
}
-(void) setTopBarTitle:(NSString *) title{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.topViewController.title = title;
    });
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   

}




@end
