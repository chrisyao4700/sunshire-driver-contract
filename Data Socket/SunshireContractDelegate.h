//
//  SunshireContractDelegate.h
//  SunshireDriverContract
//
//  Created by 姚远 on 5/12/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SunshireContractDelegate <NSObject>
@required
-(void) dataSocketWillStartRequestWithTag:(NSInteger) tag
                           andCustomerTag:(NSInteger) c_tag;
-(void) dataSocketDidGetResponseWithTag:(NSInteger)tag
                         andCustomerTag:(NSInteger) c_tag;
-(void) dataSocketErrorWithTag:(NSInteger)tag andMessage: (NSString *) message
                andCustomerTag:(NSInteger) c_tag;


@optional
-(void) dataSocketDidFinishConnectionCheckWithMessage:(NSString *) message
                                       andCustomerTag:(NSInteger) c_tag;
-(void) dataSocketDidLogonWithMessage:(NSString *)message
                              forUser:(NSDictionary *) anUser
                       andCustomerTag:(NSInteger) c_tag;
-(void) dataSocketDidInsertUserWithMessage:(NSString *)message
                                   forUser:(NSDictionary *) anUser
                            andCustomerTag:(NSInteger) c_tag;
-(void) datasocketDidReceiveNormalResponseWithDict:(NSDictionary *) resultDic
                                    andCustomerTag:(NSInteger) c_tag;
@end
