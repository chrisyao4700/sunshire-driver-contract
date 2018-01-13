//
//  CurrentUserManager.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SS_CONTRACT_USER+CoreDataClass.h"
#import "APP_INFO+CoreDataClass.h"
#import "CURRENT_LOCATION+CoreDataClass.h"
#import "CurrentUserDelegate.h"
#import "SunshireContractConnector.h"
@interface CurrentUserManager : NSObject<SunshireContractDelegate>
@property id <CurrentUserDelegate> delegate;
- (instancetype)initWithDelegate:(id)aDelegate;

+(SS_CONTRACT_USER *) getCurrentContractUser;
+(APP_INFO * ) getAppInfoToken;
+(CURRENT_LOCATION *) getCurrentLocation;
+(void) saveCurrentLocationWithLatitude:(double) latitude
                           andLongitude:(double) longitude;
+(void) saveCurrentLocationWithTripID:(NSString *) tripID;

+(void) saveAppInfoTokenWithMap:(NSDictionary *) dict;

-(void) loginWithUsername:(NSString *) username
              andPassword:(NSString *) password;
-(void) updateCurrentUserWithPack:(NSDictionary *) pack;
@end
