//
//  CurrentUserManager.m
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import "CurrentUserManager.h"
#import "AppDelegate.h"
#import "CYFunctionSet.h"

@implementation CurrentUserManager{
    SunshireContractConnector * connector;
}



- (instancetype)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        self.delegate = aDelegate;
    }
    return self;
}

/* Coredata */

#pragma mark CURRENT_LOCATION
+(CURRENT_LOCATION *) getCurrentLocation{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [CURRENT_LOCATION fetchRequest];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
}
+(void) saveCurrentLocationWithLatitude:(double) latitude
                           andLongitude:(double) longitude{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    CURRENT_LOCATION * current_location = [CurrentUserManager getCurrentLocation];
    if (current_location) {
        current_location.latitude = (NSDecimalNumber *)[NSNumber numberWithDouble:latitude];
        current_location.longitude = (NSDecimalNumber *)[NSNumber numberWithDouble:longitude];
        current_location.last_update = [NSDate date];
        //current_location.trip_id = trip_id;
    }else{
        current_location  = (CURRENT_LOCATION *)[NSEntityDescription insertNewObjectForEntityForName:@"CURRENT_LOCATION" inManagedObjectContext:managedObjectContext];
        current_location.latitude = (NSDecimalNumber *)[NSNumber numberWithDouble:latitude];
        current_location.longitude = (NSDecimalNumber *)[NSNumber numberWithDouble:longitude];
        current_location.last_update = [NSDate date];
        //current_location.trip_id = trip_id;
    }
    NSError * error;
    [managedObjectContext save:&error];
}
+(void) saveCurrentLocationWithTripID:(NSString *)tripID{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    CURRENT_LOCATION * current_location = [CurrentUserManager getCurrentLocation];
    if (current_location) {
        //current_location.latitude = (NSDecimalNumber *)[NSNumber numberWithDouble:latitude];
        //current_location.longitude = (NSDecimalNumber *)[NSNumber numberWithDouble:longitude];
        //current_location.last_update = [NSDate date];
        current_location.trip_id = tripID;
    }else{
        current_location  = (CURRENT_LOCATION *)[NSEntityDescription insertNewObjectForEntityForName:@"CURRENT_LOCATION" inManagedObjectContext:managedObjectContext];
        //current_location.last_update = [NSDate date];
        current_location.trip_id = tripID;
    }
    NSError * error;
    [managedObjectContext save:&error];
}

-(NSManagedObjectContext *) configCoredataContext{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    return managedObjectContext;
}
-(void) saveAppInfoTokenObjectWithMap:(NSDictionary *) dict{
    NSManagedObjectContext* managedObjectContext = [self configCoredataContext];
    APP_INFO * info_token = [self searchAppInfoToken];
    if (info_token) {
        info_token.device_token = [dict objectForKey:@"device_token"];
        info_token.udid = [dict objectForKey:@"udid"];
    }else{
        info_token  = (APP_INFO *)[NSEntityDescription insertNewObjectForEntityForName:@"APP_INFO" inManagedObjectContext:managedObjectContext];
        info_token.device_token = [dict objectForKey:@"device_token"];
        info_token.udid = [dict objectForKey:@"udid"];
    }
    NSError * error;
    [managedObjectContext save:&error];
}
+(void) saveAppInfoTokenWithMap:(NSDictionary *) dict{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    APP_INFO * info_token = [CurrentUserManager getAppInfoToken];
    if (info_token) {
        info_token.device_token = [dict objectForKey:@"device_token"];
        info_token.udid = [dict objectForKey:@"udid"];
    }else{
        info_token  = (APP_INFO *)[NSEntityDescription insertNewObjectForEntityForName:@"APP_INFO" inManagedObjectContext:managedObjectContext];
        info_token.device_token = [dict objectForKey:@"device_token"];
        info_token.udid = [dict objectForKey:@"udid"];
    }
    NSError * error;
    [managedObjectContext save:&error];
}
-(APP_INFO *) searchAppInfoToken{
    NSManagedObjectContext* managedObjectContext = [self configCoredataContext];
    NSFetchRequest *request = [APP_INFO fetchRequest];
    
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
}



+(APP_INFO *) getAppInfoToken{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [APP_INFO fetchRequest];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
}
#pragma mark - Current User;

-(void) saveCurrentUserWithMap:(NSDictionary *) dict{
    NSManagedObjectContext* managedObjectContext = [self configCoredataContext];
    SS_CONTRACT_USER * contract_user = [self searchCurrentContractUser];
    if (contract_user) {
        contract_user.name = [dict objectForKey:@"name"];
        contract_user.data_id = [dict objectForKey:@"id"];
        contract_user.phone = [dict objectForKey:@"phone"];
        contract_user.email = [dict objectForKey:@"email"];
        contract_user.username = [dict objectForKey:@"username"];
        contract_user.password = [dict objectForKey:@"password"];
         contract_user.salary_percentage = (NSDecimalNumber *)[CYFunctionSet convertStringToNumber:[dict objectForKey:@"salary_percentage"]];
    }else{
        contract_user  = (SS_CONTRACT_USER *)[NSEntityDescription insertNewObjectForEntityForName:@"SS_CONTRACT_USER" inManagedObjectContext:managedObjectContext];
        contract_user.name = [dict objectForKey:@"name"];
        contract_user.data_id = [dict objectForKey:@"id"];
        contract_user.email = [dict objectForKey:@"email"];
        contract_user.phone = [dict objectForKey:@"phone"];
        contract_user.username = [dict objectForKey:@"username"];
        contract_user.password = [dict objectForKey:@"password"];
        contract_user.salary_percentage = (NSDecimalNumber *)[CYFunctionSet convertStringToNumber:[dict objectForKey:@"salary_percentage"]];
    }
    NSError * error;
    [managedObjectContext save:&error];
}
-(SS_CONTRACT_USER *) searchCurrentContractUser{
    NSManagedObjectContext* managedObjectContext = [self configCoredataContext];
    NSFetchRequest *request = [SS_CONTRACT_USER fetchRequest];
    
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
    
}
+(SS_CONTRACT_USER *) getCurrentContractUser{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* managedObjectContext = app.persistentContainer.viewContext;
    NSFetchRequest *request = [SS_CONTRACT_USER fetchRequest];
    NSError *error = nil;
    NSArray * array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array.count == 1) {
        return [array objectAtIndex:0];
    }else{
        return nil;
    }
}
-(void) updateCurrentUserWithPack:(NSDictionary *) pack{
    if (!connector) {
        connector = [[SunshireContractConnector alloc] initWithDelegate:self];
    }
    [connector sendNormalRequestWithPack:pack andServiceCode:@"update_record" andCustomerTag:12];
}

-(void) loginWithUsername:(NSString *) username
              andPassword:(NSString *) password{
    NSDictionary * uploadpack =@{
                                 @"username": username,
                                 @"password": password,
                                 @"type": @"RAW"};
    if (!connector) {
        connector = [[SunshireContractConnector alloc] initWithDelegate:self];
    }
    [connector sendRequestForDriverLogonWithPack:uploadpack];
    
    
}
-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag{
    if (self.delegate) {
        [self.delegate currentUserManagerWillStartRequestWithTag:tag];
    }
    
}
-(void) dataSocketDidGetResponseWithTag:(NSInteger)tag
                         andCustomerTag:(NSInteger) c_tag{
    if (self.delegate) {
        [self.delegate currentUserManagerDidGetResponseWithTag:tag];
    }
    
}
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag{
    if (self.delegate) {
        [self.delegate currentUserManagerError:message forTag:tag];
    }
    
}
-(void)datasocketDidReceiveNormalResponseWithDict:(NSDictionary *)resultDic andCustomerTag:(NSInteger)c_tag{
    if (c_tag == 12) {
        [self saveCurrentUserWithMap:[resultDic objectForKey:@"record"]];
        if (self.delegate) {
            [self.delegate currentUserManagerDidUpdateCurrentUser];
        }
    }
}
-(void) dataSocketDidLogonWithMessage:(NSString *)message
                              forUser:(NSDictionary *) anUser
                       andCustomerTag:(NSInteger) c_tag{
    [self saveCurrentUserWithMap:anUser];
    if (self.delegate) {
        [self.delegate currentUserManagerLogonSuccess];
    }
}



@end
