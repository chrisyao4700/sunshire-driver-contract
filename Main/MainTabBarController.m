//
//  MainTabBarController.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UITabBarItem * tripItem = [self.tabBar.items objectAtIndex:0];
    tripItem.image = [[UIImage imageNamed:@"tab_trip_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tripItem.selectedImage = [[UIImage imageNamed:@"tab_trip_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tripItem.title = @"TRIP";

    UITabBarItem * historyItem = [self.tabBar.items objectAtIndex:1];
    historyItem.image = [[UIImage imageNamed:@"tab_history_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    historyItem.selectedImage = [[UIImage imageNamed:@"tab_history_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    historyItem.title = @"HISTORY";
    
    UITabBarItem * locationItem = [self.tabBar.items objectAtIndex:2];
    locationItem.image = [[UIImage imageNamed:@"tab_location_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    locationItem.selectedImage = [[UIImage imageNamed:@"tab_location_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    locationItem.title = @"LOCATION";
    
    UITabBarItem * profile = [self.tabBar.items objectAtIndex:3];
    profile.image = [[UIImage imageNamed:@"tab_me_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profile.selectedImage = [[UIImage imageNamed:@"tab_me_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profile.title = @"ME";
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
