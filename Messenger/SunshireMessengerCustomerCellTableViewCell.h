//
//  SunshireMessengerCustomerCellTableViewCell.h
//  SunshireDriver
//
//  Created by 姚远 on 10/19/16.
//  Copyright © 2016 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SunshireMessengerCustomerCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *cellImageView;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
