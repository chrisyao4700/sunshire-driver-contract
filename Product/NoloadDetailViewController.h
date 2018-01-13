//
//  NoloadDetailViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 6/5/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunshireContractConnector.h"
#import "DateTimeSelectorViewController.h"
@interface NoloadDetailViewController : UIViewController<SunshireContractDelegate,UITableViewDelegate,UITableViewDataSource,DateTimeSelectorDelegate>
@property NSString * noload_id;
@property (strong, nonatomic) IBOutlet UITableView *noloadView;

@end
