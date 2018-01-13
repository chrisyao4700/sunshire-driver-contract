//
//  CYPolyline.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/2/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <MapKit/MapKit.h>



@interface CYPolyline : NSObject <MKOverlay> {
    MKPolyline* polyline;
}

@property (nonatomic, retain) MKPolyline* polyline;
@property NSNumber * speed;
+ (CYPolyline *)initWithPolyline: (MKPolyline*) line
                        andSpeed: (NSNumber *) theSpeed;

@end
