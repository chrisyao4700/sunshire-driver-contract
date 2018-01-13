//
//  EarningViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/23/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunshireContractConnector.h"
#import "DatePickerViewController.h"

@interface EarningViewController : UIViewController<SunshireContractDelegate,UITableViewDataSource,UITableViewDelegate,DatePickerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *earningTable;

@end
