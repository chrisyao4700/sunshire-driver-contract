//
//  CYColorSet.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/23/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CYColorSet.h"

@implementation CYColorSet
+(UIColor *) getTranslucenceColor{
    UIColor * color = [UIColor colorWithWhite:1.0f alpha:0.4f];
    return color;
}
+(UIColor *) getMyRedColor{
    UIColor * color = [UIColor colorWithRed:0.8f green:0.0f blue:0.2f alpha:1.0f];
    return color;
}
+(UIColor *) getEightyBackgroundColor{
    UIColor * color = [UIColor colorWithWhite:1.0f alpha:0.8f];
    return color;
}
+(UIColor *) getDarkGreen{
    UIColor * color = [UIColor colorWithRed:0.01f green:0.5f blue:0.32f alpha:1.0f];
    return color;
}
@end
