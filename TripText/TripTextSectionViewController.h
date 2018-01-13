//
//  TripTextSectionViewController.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 7/21/17.
//  Copyright © 2017 Sunshireshuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunshireContractConnector.h"
#import "UIViewController+CYViewController.h"
#import "TripTextPreviewViewController.h"
#import "TripTextSectionDelegate.h"
@interface TripTextSectionViewController : UIViewController<SunshireContractDelegate,UITableViewDataSource,UITableViewDelegate,TripTextPreviewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *contentTable;
@property id<TripTextSectionDelegate> delegate;
@property NSString * sectionID;
@property NSString * tripID;

@end
