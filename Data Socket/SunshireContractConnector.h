//
//  SunshireContractConnector.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SunshireContractDelegate.h"
@interface SunshireContractConnector : NSObject
@property id <SunshireContractDelegate> delegate;
- (instancetype)initWithDelegate:(id) aDelegate;

-(void) sendVersionAPIVerificationRequest;
-(void) sendRequestForDriverLogonWithPack:(NSDictionary *) dataPack;

-(void) sendNormalRequestWithPack:(NSDictionary *) dataPack
                   andServiceCode:(NSString * ) service_code
                   andCustomerTag:(NSInteger) c_tag;

-(void) sendNormalRequestWithPack:(NSDictionary *) dataPack
                   andServiceCode:(NSString * )service_code
                   andCustomerTag:(NSInteger) c_tag
                andWillStartBlock:(void (^)(NSInteger c_tag)) willStartHandler
              andGotResponseBlock:(void (^)(NSInteger c_tag)) gotResponseHandler
                    andErrorBlock:(void (^)(NSInteger c_tag, NSString * message)) errorHandler
                  andSuccessBlock:(void (^)(NSInteger c_tag, NSDictionary * resultDict)) successHandler;
@end
