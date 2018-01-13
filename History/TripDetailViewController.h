//
//  TripDetailViewController.h
//  SunshireDriver
//
//  Created by 姚远 on 11/19/16.
//  Copyright © 2016 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SunshireContractConnector.h"

@interface TripDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,SunshireContractDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *tripMap;

@property (strong, nonatomic) IBOutlet UITableView *infoTable;


@property NSString * trip_history_id;

@end
