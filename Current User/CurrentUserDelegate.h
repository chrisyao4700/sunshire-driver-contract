//
//  CurrentUserDelegate.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CurrentUserDelegate <NSObject>
@required
-(void) currentUserManagerWillStartRequestWithTag:(NSInteger) tag;
-(void) currentUserManagerDidGetResponseWithTag:(NSInteger) tag;
-(void) currentUserManagerError:(NSString *) messsage
                         forTag:(NSInteger)tag;
@optional
-(void) currentUserManagerLogonSuccess;
-(void) currentUserManagerDidUpdateCurrentUser;

@end
