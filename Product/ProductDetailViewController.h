//
//  ProductDetailViewController.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/31/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SunshireContractConnector.h"

@interface ProductDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,SunshireContractDelegate>

@property NSString * product_id;
@property (strong, nonatomic) IBOutlet UITableView *tripInfoView;
@property (strong, nonatomic) IBOutlet UICollectionView *actionCollectionView;

@end
