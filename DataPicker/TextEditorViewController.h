//
//  TextEditorViewController.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/3/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextEditorDelegate.h"
@interface TextEditorViewController : UIViewController<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *contentField;


@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property id<TextEditorDelegate> delegate;
@property NSString * key;
@property NSString * orgValue;

@end
