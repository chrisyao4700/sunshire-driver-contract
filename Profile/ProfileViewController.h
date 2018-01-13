//
//  ProfileViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/23/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentUserManager.h"

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,CurrentUserDelegate>
@property (strong, nonatomic) IBOutlet UITableView *profileTable;

@end
