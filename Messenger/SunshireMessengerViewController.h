//
//  SunshireMessengerViewController.h
//  SunshireDriver
//
//  Created by 姚远 on 10/19/16.
//  Copyright © 2016 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TextEditorViewController.h"
#import "SunshireContractConnector.h"

@interface SunshireMessengerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,TextEditorDelegate,SunshireContractDelegate>
@property (strong, nonatomic) IBOutlet UITableView *messengerTableView;

@property NSString * contact_id;

@end
