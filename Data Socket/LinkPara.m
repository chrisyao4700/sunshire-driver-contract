//
//  LinkPara.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/15/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "LinkPara.h"

@implementation LinkPara
+(NSString *) getRootLinkAddress{
    return @"https://sunshireshuttle.com";
}
+(NSString *) getAPIDirectory{
    return @"chrisyao4700/app_socket.php";
}
+(NSString *) getAPIKey{
    return @"chrisyao19900908";
}
+(NSString *) getUpdateLink{
    return @"https://sunshireshuttle.com/Apps/SunshireDriver/Install/excute.html";
}
+(NSString *) getVersionCode{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *erped_version = [NSString stringWithFormat:@"ios.driver.%@",version];
    return erped_version;
}
@end
