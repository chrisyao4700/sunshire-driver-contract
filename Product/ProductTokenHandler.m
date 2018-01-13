//
//  ProductTokenHandler.m
//  SunshireDriverContract
//
//  Created by 姚远 on 5/31/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "ProductTokenHandler.h"
#import "AppDelegate.h"


@implementation ProductTokenHandler

+(PRODUCT_TOKEN *) getProductTokenWithID:(NSString *) product_id{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [PRODUCT_TOKEN fetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"product_id == %@",product_id]];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count > 0) {
        return [array objectAtIndex:0];
    }else{
        PRODUCT_TOKEN * token = (PRODUCT_TOKEN *)[NSEntityDescription insertNewObjectForEntityForName:@"PRODUCT_TOKEN" inManagedObjectContext:managedObjectContext];
        token.is_sent_eta = NO;
        token.is_sent_arrival = NO;
        token.is_sent_cob = NO;
        token.is_sent_cad = NO;
        token.product_id = product_id;
        NSError *s_error = nil;
        [managedObjectContext save:&s_error];
        return token;
    }
}
+(void) removeProductTokenWithID:(NSString *) product_id{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [PRODUCT_TOKEN fetchRequest];
    [request setPredicate:[NSPredicate predicateWithFormat:@"product_id == %@",product_id]];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    
    for (PRODUCT_TOKEN * token in array) {
        [managedObjectContext deleteObject:token];
    }
    NSError *s_error = nil;
    [managedObjectContext save:&s_error];
    
}
+(void) saveChanges{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSError *error = nil;
    [managedObjectContext save:&error];
}


@end
