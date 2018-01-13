//
//  LocationViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/18/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "LocationViewController.h"
#import "CurrentUserManager.h"
#import "CYColorSet.h"

@interface LocationViewController ()

@end

@implementation LocationViewController{
    SunshireContractConnector * connector;
    
    NSNumber * is_sharing;
    
    UIBarButtonItem * rightItem;
    
    UIAlertController * alert;
    UIActivityIndicatorView * loadingView;
    NSTimer * updateLocationTimer;
    NSTimer * reconnectTimer;
    NSTimer * quarterLockTimer;
    
    CURRENT_LOCATION * currentLocation;
    
    CLLocationManager * locationManager;
    
    //NSString * trip_id;
    
    SS_CONTRACT_USER * driver_info;
    
    
    NSInteger location_update_tag;
    
    
    NSTimer * updateTimer;
    NSTimer * minuteDispatcher;
    NSTimer * quarterDispatcher;
}
-(void)viewWillAppear:(BOOL)animated{
    [self requestDriverSharingStatus];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self configRightBarButtonItem];
    [self configActionButton];
    [self configMapView];
    [self setNavigationBarString:@"LOCATION"];
    self.onlineIndicator.backgroundColor = [CYColorSet getTranslucenceColor];

}
#pragma mark BarItem
-(void) configRightBarButtonItem{
    rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(IBAction)rightButtonClicked:(id)sender{
    if (locationManager.allowsBackgroundLocationUpdates == NO) {
        [self showAlertWithTittle:@"错误❌" forMessage:@"请开启位置分享服务"];
    }
    [self requestDriverSharingStatus];
    
}
-(void) configMapView{
    self.locationMap.showsUserLocation = YES;
    [self.locationMap setMapType:MKMapTypeStandard];
    [self.locationMap setZoomEnabled:YES];
    [self.locationMap setScrollEnabled:YES];
    self.locationMap.delegate = self;
    self.locationMap.alpha = 0.90;
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc]init];
    }
    
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];

    [locationManager setAllowsBackgroundLocationUpdates:YES];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

}



-(void) focusMapLocation{
        MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
        currentLocation = [CurrentUserManager getCurrentLocation];
        region.center.latitude = currentLocation.latitude.doubleValue;
        region.center.longitude = currentLocation.longitude.doubleValue;
        region.span.longitudeDelta = 0.06f;
        region.span.longitudeDelta = 0.06f;
        [self.locationMap setRegion:region animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestDriverSharingStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        is_sharing = nil;
        [self.actionButton setHidden:YES] ;
        driver_info = [CurrentUserManager getCurrentContractUser];
        NSDictionary * dict = @{
                                @"driver_id": driver_info.data_id
                                };
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        [connector sendNormalRequestWithPack:dict andServiceCode:@"check_sharing" andCustomerTag:1];
    });
}
-(void) configStatusLabelText:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusLabel setText:str];
    });
}
-(void) configActionButtonText:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.actionButton setTitle:str forState:UIControlStateNormal];
    });
}
-(void) configActionButtonStatus:(BOOL) flag{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.actionButton setUserInteractionEnabled:flag];
    });
}
-(void) configActionButtonTextColor:(UIColor *) aColor{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.actionButton.titleLabel setTextColor:aColor];
    });
}
-(void) updateActionButtonTitle{
    if (is_sharing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.actionButton setHidden:NO];
        });
        if (is_sharing.boolValue == YES) {
            [self configActionButtonTextColor:[CYColorSet getMyRedColor]];
            [self configActionButtonText:@"结束分享"];
        }
        if (is_sharing.boolValue == NO) {
            [self configActionButtonTextColor:[UIColor whiteColor]];
            [self configActionButtonText:@"开始分享"];
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.actionButton setHidden:YES];
        });
    }
    
}

-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    [self loadingStart];
    [self configActionButtonStatus:NO];
    if (c_tag == 1) {
        [self configStatusLabelText:@"CHECKING SHARING STATUS..."];
    }
    
    if (c_tag == 2) {
        [self configStatusLabelText:@"STARTING LOCATION SHARE..."];
    }
    
    if (c_tag == 3) {
        [self configStatusLabelText:@"ENDING LOCATION SHARE..."];
    }
    
    if (c_tag == 4) {
        [self configStatusLabelText:@"UPLOADING LOCATION..."];
    }
    
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger) tag
                         andCustomerTag:(NSInteger) c_tag{
    [self loadingStop];
    [self configActionButtonStatus:YES];
    if (c_tag == 1) {
        [self configStatusLabelText:@"SHARING STATUS CHECKED"];
    }
    if (c_tag == 2) {
        [self configStatusLabelText:@"SHARING REQUEST SENT"];
    }
    if (c_tag == 3) {
        [self configStatusLabelText:@"ENDING REQUEST SENT"];
    }
    if (c_tag == 4) {
        [self configStatusLabelText:@"UPLOADING LOCATION"];
    }
    
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    if (c_tag == 1) {
        [self showAlertWithTittle:@"ERROR" forMessage:message];
        [self updateActionButtonTitle];
    }
    if (c_tag == 2) {
        [self configStatusLabelText:[NSString stringWithFormat:@"ERROR:%@",message]];
    }
    

}
-(void) updateOnlineIndicatorText:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.onlineIndicator setText:str];
    });
}
-(void) updateOnlineIndicatorColor:(UIColor *) color{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.onlineIndicator setTextColor:color];
    
    });
}

-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 1) {
        //checking sharing
        is_sharing = (NSNumber *)[resultDic objectForKey:@"is_sharing"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [locationManager startUpdatingLocation];
            if (is_sharing.boolValue == NO) {
                [self configStatusLabelText:@"DRIVER OFFLINE"];
                [self updateOnlineIndicatorText:@"下线状态"];
                [self updateOnlineIndicatorColor:[UIColor redColor]];
                
            }
            if (is_sharing.boolValue == YES) {
                [self updateSharingStream];
                [self updateOnlineIndicatorText:@"正在分享位置"];
                [self updateOnlineIndicatorColor:[CYColorSet getDarkGreen]];
            }
        });
        [self updateActionButtonTitle];
    }
    if (c_tag == 2) {
        [self requestDriverSharingStatus];
   
    }
    if (c_tag == 3) {
        [CurrentUserManager saveCurrentLocationWithTripID:@"N/A"];
        [self requestDriverSharingStatus];
    }
    
    if (c_tag == 4) {
        [self configStatusLabelText:@"LOCATION UPLOADED"];
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


#pragma mark - locatoin manager
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [CurrentUserManager saveCurrentLocationWithLatitude:manager.location.coordinate.latitude andLongitude:manager.location.coordinate.longitude];
    [self locationDidUpdatedWithTag:location_update_tag];
    [self focusMapLocation];
    
    
    if (is_sharing.boolValue == NO) {
        [locationManager stopUpdatingLocation];
    }
    if (is_sharing.boolValue == YES) {
        [locationManager startUpdatingLocation];
    }
}

#pragma mark action button
- (IBAction)didClickActionButton:(id)sender {
    if (locationManager.locationServicesEnabled == NO) {
        [self showAlertWithTittle:@"错误❌" forMessage:@"请打开位置分享服务"];
    }
    if (is_sharing.boolValue == NO) {
        [self requestStartShareLocation];
    }
    if (is_sharing.boolValue == YES) {
        [self requestEndShareLocation];
    }
}
-(void) requestStartShareLocation{
    [CurrentUserManager saveCurrentLocationWithTripID:[self configTripId]];
    currentLocation = [CurrentUserManager getCurrentLocation];
    NSDate * nowDate = [NSDate date];
    NSTimeInterval intervel = [nowDate timeIntervalSinceDate:currentLocation.last_update];
    if (intervel > 30) {
        location_update_tag = 2;
        [locationManager startUpdatingLocation];
    }else{
        [self sendRequestForUpdateLocationWithAction:@"1" forTag:2];
    }
}
-(void) sendRequestForUpdateLocationWithAction:(NSString *) action
                                        forTag:(NSInteger) tag{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!driver_info) {
            driver_info = [CurrentUserManager getCurrentContractUser];
        }
        currentLocation = [CurrentUserManager getCurrentLocation];
        
        NSDictionary * dict = @{
                                @"trip_id":currentLocation.trip_id,
                                @"driver_code":driver_info.data_id,
                                @"action":action,
                                @"latitude":[NSString stringWithFormat:@"%lf",currentLocation.latitude.doubleValue],
                                @"longitude":[NSString stringWithFormat:@"%lf",currentLocation.longitude.doubleValue]
                                };
        if (!connector) {
            connector = [[SunshireContractConnector alloc] initWithDelegate:self];
        }
        [connector sendNormalRequestWithPack:dict andServiceCode:@"update_location" andCustomerTag:tag];
    
    });
    
}

-(void) locationDidUpdatedWithTag:(NSInteger) tag{
    if (tag == 2) {
        location_update_tag = 0;
        [self sendRequestForUpdateLocationWithAction:@"1" forTag:tag];
    }
    if (tag == 3) {
        location_update_tag = 0;
        [self sendRequestForUpdateLocationWithAction:@"9" forTag:tag];
    }
    if (tag == 4) {
        [self sendRequestForUpdateLocationWithAction:@"3" forTag:tag];
    }
    
}
-(void) requestEndShareLocation{
    
    [self muteAllTimer];
    currentLocation = [CurrentUserManager getCurrentLocation];
    NSDate * nowDate = [NSDate date];
    NSTimeInterval intervel = [nowDate timeIntervalSinceDate:currentLocation.last_update];
    if (intervel > 30) {
        location_update_tag = 3;
        [locationManager startUpdatingLocation];
    }else{
        [self sendRequestForUpdateLocationWithAction:@"9" forTag:3];
    }
}
-(NSString *) configTripId{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * nowDate = [NSDate date];
    if (!driver_info) {
        driver_info = [CurrentUserManager getCurrentContractUser];
    }
    NSString * str= [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:nowDate],driver_info.data_id];
    return str;
}

#pragma status label
-(void) configStatusLabelString:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusLabel setText:str];
    });
}
-(void) configActionButton{
    
    self.actionButton.backgroundColor = [CYColorSet getTranslucenceColor];
    self.actionButton.layer.cornerRadius = 20.0;
    [self.actionButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.actionButton.layer.shadowOpacity = 0.5;
    self.actionButton.layer.shadowOffset = CGSizeMake(0.5, 5.0);
    self.actionButton.layer.shadowRadius = 5.0;
    
    
    self.statusLabel.backgroundColor = [CYColorSet getTranslucenceColor];
}


/* Global Sharing...*/
-(void) updateSharingStream{
    [self muteAllTimer];
    if(!quarterDispatcher){
        [self quarterTimerDidFire:nil];
        quarterDispatcher = [NSTimer scheduledTimerWithTimeInterval:900
                                                             target:self
                                                           selector:@selector(quarterTimerDidFire:)
                                                           userInfo:nil
                                                            repeats:YES];
    }else{
        [self quarterTimerDidFire:nil];
        quarterDispatcher = [NSTimer scheduledTimerWithTimeInterval:900
                                                             target:self
                                                           selector:@selector(quarterTimerDidFire:)
                                                           userInfo:nil
                                                            repeats:YES];
        
    }
    
}

-(void) quarterTimerDidFire:(NSTimer *) timer{
    [self muteMinuteTimer];
    if (!minuteDispatcher) {
        [self minuteTimerDidFire:nil];
        minuteDispatcher = [NSTimer scheduledTimerWithTimeInterval:60
                                                            target:self
                                                          selector:@selector(minuteTimerDidFire:)
                                                          userInfo:nil
                                                           repeats:YES];
    }else{
        [self minuteTimerDidFire:nil];
        minuteDispatcher = [NSTimer scheduledTimerWithTimeInterval:60
                                                            target:self
                                                          selector:@selector(minuteTimerDidFire:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}
-(void) minuteTimerDidFire:(NSTimer *) timer{
    [self muteUpdateTimer];
    if (!updateTimer) {
        [self updateTimerDidFire:nil];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                       target:self
                                                     selector:@selector(updateTimerDidFire:)
                                                     userInfo:nil
                                                      repeats:YES];
    }else{
        [self updateTimerDidFire:nil];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                       target:self
                                                     selector:@selector(updateTimerDidFire:)
                                                     userInfo:nil
                                                      repeats:YES];
        
    }
}
-(void) updateTimerDidFire:(NSTimer *) timer{
    [self sendRequestForUpdateLocationWithAction:@"3" forTag:4];
}
-(void)muteUpdateTimer{
    [updateTimer invalidate];
    updateTimer = nil;
}
-(void)muteMinuteTimer{
    [minuteDispatcher invalidate];
    minuteDispatcher = nil;
}
-(void) muteQuarterTimer{
    [quarterDispatcher invalidate];
    quarterDispatcher = nil;
}

-(void) muteAllTimer{
    [self muteQuarterTimer];
    [self muteMinuteTimer];
    [self muteUpdateTimer];
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
