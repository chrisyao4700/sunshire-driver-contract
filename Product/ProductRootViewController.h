//
//  ProductRootViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/30/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunshireContractConnector.h"
@interface ProductRootViewController : UIViewController<SunshireContractDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *productTable;

@end
