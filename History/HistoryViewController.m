//
//  HistoryViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/23/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController{
    UIActivityIndicatorView * loadingView;
    UIAlertController * alert;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.segmentController setTintColor:[UIColor whiteColor]];
    [self configLoadingView];
    //[self revealEarningView];
    self.earningContainer.alpha = 1.0;
    self.calendarContainer.alpha = 0.0;
    
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentControllerDidChange:(id)sender {
    if (self.segmentController.selectedSegmentIndex == 0) {
        [self revealEarningView];
    }
    if (self.segmentController.selectedSegmentIndex == 1) {
        [self revealCalendarView];
    }
    
}

-(void) revealEarningView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.earningContainer.alpha = 1.0;
            self.calendarContainer.alpha = 0.0;
        } completion:^(BOOL finished){
        
            [self setNavigationBarString:@"EARNING"];
        
        
        }];
    
    });
    
}
-(void) revealCalendarView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.earningContainer.alpha = 0.0;
            self.calendarContainer.alpha = 1.0;
        } completion:^(BOOL finished){
            
            [self setNavigationBarString:@"CALENDAR"];
            
            
        }];
        
    });
    
}

#pragma loading and alert

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

-(void) configLoadingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [loadingView setHidesWhenStopped:YES];
        loadingView.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
        [self.view addSubview:loadingView];
    });
}
-(void) setNavigationBarString:(NSString *) str{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.topViewController.title = str;
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
