//
//  AppCoreDataSocket.h
//  SunshireDriverContract
//
//  Created by Yuan Yao on 1/13/18.
//  Copyright © 2018 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SS_TRIP+CoreDataClass.h"

@interface AppCoreDataSocket : NSObject
+(void) saveTripListToCoreData:(NSArray *) tripList;
+(NSManagedObjectContext *) getContext;
+(SS_TRIP *) getTripWithID:(NSString *) trip_id;
@end
