//
//  TripTextRootViewController.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 7/21/17.
//  Copyright © 2017 Sunshireshuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunshireContractConnector.h"
#import "UIViewController+CYViewController.h"
#import "TripTextSectionViewController.h"
@interface TripTextRootViewController : UIViewController<SunshireContractDelegate,UITableViewDelegate,UITableViewDataSource,TripTextSectionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property NSString * tripID;

@end
