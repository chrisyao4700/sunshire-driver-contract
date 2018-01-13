//
//  TripTextPreviewDelegate.h
//  SunshireDriverContract
//
//  Created by 姚远 on 7/22/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TripTextPreviewDelegate <NSObject>

-(void) tripTextPreviewDidSendText:(NSString *) text;
-(void) tripTextPreviewDidCancel;

@end
