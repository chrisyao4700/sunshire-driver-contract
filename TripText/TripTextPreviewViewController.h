//
//  TripTextPreviewViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 7/22/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripTextPreviewDelegate.h"
@interface TripTextPreviewViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *infoView;
@property NSString * textContent;
@property id<TripTextPreviewDelegate> delegate;
@end
