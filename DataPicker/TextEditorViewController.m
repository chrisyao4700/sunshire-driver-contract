//
//  TextEditorViewController.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/3/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import "TextEditorViewController.h"

@interface TextEditorViewController ()

@end

@implementation TextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.view.backgroundColor = [UIColor clearColor];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didClickCancel:(id)sender {
    [_delegate didCancelTextSelectingForKey:_key];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didClickSave:(id)sender {
    [_delegate didSaveTextForKey:_key andText:_contentField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
 */
-(void)viewWillAppear:(BOOL)animated{
    if (!_orgValue) {
        _orgValue = @"";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _contentField.text = _orgValue;
         _keyLabel.text = _key;
    });
    

    [_contentField becomeFirstResponder];
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
