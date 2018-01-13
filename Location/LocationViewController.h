//
//  LocationViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/18/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SunshireContractConnector.h"
@interface LocationViewController : UIViewController<MKMapViewDelegate,SunshireContractDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *locationMap;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *onlineIndicator;

@end
