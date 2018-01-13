//
//  ProductRootTableViewCell.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/30/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductRootTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *product_id_label;
@property (strong, nonatomic) IBOutlet UILabel *from_address_label;
@property (strong, nonatomic) IBOutlet UILabel *to_address_label;
@property (strong, nonatomic) IBOutlet UILabel *service_type_label;

@property (strong, nonatomic) IBOutlet UILabel *pickuptime_label;
@property (strong, nonatomic) IBOutlet UILabel *status_label;

@end
