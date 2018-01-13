//
//  ProductTokenHandler.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/31/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRODUCT_TOKEN+CoreDataClass.h"

@interface ProductTokenHandler : NSObject
+(PRODUCT_TOKEN *) getProductTokenWithID:(NSString *) product_id;
+(void) removeProductTokenWithID:(NSString *) product_id;
+(void) saveChanges;
@end
