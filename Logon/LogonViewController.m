//
//  LogonViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/11/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "LogonViewController.h"
#import "LinkPara.h"
@interface LogonViewController ()

@end

@implementation LogonViewController{
    
UIActivityIndicatorView * loadingView;
UIAlertController * alert;

SS_CONTRACT_USER * defaultUser;
CurrentUserManager * userManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoadingView];
    [self.passwordField setSecureTextEntry:YES];
    [self.versionLabel setText:[NSString stringWithFormat:@"V. %@", [LinkPara getVersionCode]]];
    //self.usernameField.delegate = self;
    //self.passwordField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    defaultUser = [CurrentUserManager getCurrentContractUser];
    if (defaultUser) {
        self.usernameField.text = defaultUser.username;
    }
}

-(void) changeStatusOfSignInButton:(BOOL) flag{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.signInButton.userInteractionEnabled = flag;
    });
}

-(void) currentUserManagerWillStartRequestWithTag:(NSInteger) tag{
    [self loadingStart];
    [self setSignInButtonText:@"链接中.."];
    [self changeStatusOfSignInButton:NO];
}
-(void) currentUserManagerDidGetResponseWithTag:(NSInteger) tag{
    [self loadingStop];
    [self setSignInButtonText:@"登入"];
    [self changeStatusOfSignInButton:YES];
}
-(void) currentUserManagerError:(NSString *) messsage
                         forTag:(NSInteger)tag{
    [self showAlertWithTittle:@"错误❌" forMessage:messsage];
}
-(void) currentUserManagerLogonSuccess{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.passwordField.text = @"";
        //NSString* identifier_str = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        APP_INFO * info_token = [CurrentUserManager getAppInfoToken];
        
        if (!defaultUser) {
            defaultUser = [CurrentUserManager getCurrentContractUser];
        }
        if (info_token && info_token.device_token) {
            NSArray * elements = @[@{
                                       @"key": @"push_code",
                                       @"value": info_token.device_token
                                       }];
            NSDictionary * uploadpack = @{
                                          @"element_array":elements,
                                          @"table_name": @"driver",
                                          @"data_id": defaultUser.data_id
                                          };
            [userManager updateCurrentUserWithPack:uploadpack];
            
        }else{
            [self showAlertWithTittle:@"错误❌" forMessage:@"无法在不使用提醒服务的情况下登入"];
        }
    });
    
}
-(void)currentUserManagerDidUpdateCurrentUser{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"logonToMain" sender:self];
    });
}


-(void) setSignInButtonText:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.signInButton.titleLabel.text = str;
    });
}

-(void) loadingStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView startAnimating];
    });
    
}
-(void) loadingStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingView stopAnimating];
    });
}
-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
    
}
-(void) showAlertWithTittle:(NSString *) tittle
                 forMessage:(NSString *) message{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
        alert = [UIAlertController
                 alertControllerWithTitle:tittle
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // Handle further action
                                                             
                                                         }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    });
    
}

#define kOFFSET_FOR_KEYBOARD 250.0

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


-(void)setViewMoveUp{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        CGRect rect = self.view.frame;
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        
        self.view.frame = rect;
        [UIView commitAnimations];
    });
}
-(void) setViewMoveDown{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        CGRect rect = self.view.frame;
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        self.view.frame = rect;
        [UIView commitAnimations];
    });
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self setViewMoveDown];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self setViewMoveUp];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"logonToMain"]) {
        self.passwordField.text = @"";
    }
}

- (IBAction)didClickSignIn:(id)sender {
    if (!userManager) {
        userManager = [[CurrentUserManager alloc] initWithDelegate:self];
        
    }
    [userManager loginWithUsername:self.usernameField.text andPassword:self.passwordField.text];
    [self.view endEditing:YES];

}

@end
