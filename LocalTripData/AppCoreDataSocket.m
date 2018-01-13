//
//  AppCoreDataSocket.m
//  SunshireDriverContract
//
//  Created by Yuan Yao on 1/13/18.
//  Copyright © 2018 SunshireShuttle. All rights reserved.
//

#import "AppCoreDataSocket.h"
#import "AppDelegate.h"

@implementation AppCoreDataSocket

+(SS_TRIP *) getTripWithID:(NSString *) trip_id{
    NSManagedObjectContext * context = [AppCoreDataSocket getContext];
    NSFetchRequest *request = [SS_TRIP fetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"trip_id == %@",trip_id]];
    NSError *error = nil;
    NSArray * array = [context executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return array[0];
    }
    return nil;
}
+(void) saveTripListToCoreData:(NSArray *) tripList{
    [AppCoreDataSocket deleteAllTripList];
    NSManagedObjectContext * context = [AppCoreDataSocket getContext];
    //NSMutableArray * list = [[NSMutableArray alloc]init];
    for (NSDictionary * aTrip in tripList) {
         SS_TRIP * trip = (SS_TRIP *)[NSEntityDescription insertNewObjectForEntityForName:@"SS_TRIP" inManagedObjectContext: context];
        trip.location_from = [aTrip objectForKey:@"location_from"];
        trip.location_to = [aTrip objectForKey:@"location_to"];
        trip.pickup_time = [aTrip objectForKey:@"pickup_time"];
        trip.service_type = [aTrip objectForKey:@"service_type"];
        trip.status_str = [aTrip objectForKey:@"status_str"];
        trip.trip_id = [aTrip objectForKey:@"id"];
        
        //[list addObject:trip];
    }
    [AppCoreDataSocket saveContext:context];
    //return list;
}

+(void) deleteAllTripList{
    NSFetchRequest *request = [SS_TRIP fetchRequest];
    NSManagedObjectContext * context = [AppCoreDataSocket getContext];
    NSError *error = nil;
    NSArray * array = [context executeFetchRequest:request error:&error];
    if (array.count > 0) {
        for (SS_TRIP * aTrip in array) {
            [context deleteObject:aTrip];
        }
        [AppCoreDataSocket saveContext:context];
    }
}
+(NSManagedObjectContext *) getContext{
   AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
   return app.persistentContainer.viewContext;
}

+(void) saveContext:(NSManagedObjectContext *) context{
    NSError *s_error = nil;
    [context save:&s_error];
}
@end
