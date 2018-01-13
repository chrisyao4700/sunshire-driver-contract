//
//  NoLoadRootTableViewCell.h
//  SunshireDriverContract
//
//  Created by 姚远 on 6/5/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoLoadRootTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *from_label;
@property (strong, nonatomic) IBOutlet UILabel *to_label;
@property (strong, nonatomic) IBOutlet UILabel *trip_time_label;

@end
