//
//  CYContentTableViewCell.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/31/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYContentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *content_title_label;
@property (strong, nonatomic) IBOutlet UITextView *content_text_view;

@end
