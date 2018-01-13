//
//  LogonViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentUserManager.h"

@interface LogonViewController : UIViewController<CurrentUserDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameField;

@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@end
