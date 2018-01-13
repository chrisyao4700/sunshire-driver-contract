//
//  TripTextPreviewViewController.m
//  SunshireDriverContract
//
//  Created by 姚远 on 7/22/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "TripTextPreviewViewController.h"

@interface TripTextPreviewViewController ()

@end

@implementation TripTextPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoView.text = self.textContent;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didClickSend:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate tripTextPreviewDidSendText:self.infoView.text];
            
        }
    }];
}
- (IBAction)didClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate tripTextPreviewDidCancel];
        }
    }];
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
