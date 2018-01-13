//
//  CYPolyline.m
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/2/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import "CYPolyline.h"

@implementation CYPolyline

@synthesize polyline;


+ (CYPolyline*)initWithPolyline: (MKPolyline*) line
                       andSpeed:(NSNumber *) theSpeed{
    CYPolyline* anchorLine = [[CYPolyline alloc] init];
    anchorLine.polyline = line;
    anchorLine.speed = theSpeed;
    return anchorLine;
}


#pragma mark MKOverlay
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (CLLocationCoordinate2D) coordinate {
    return [polyline coordinate];
}

//@property (nonatomic, readonly) MKMapRect boundingMapRect;
- (MKMapRect) boundingMapRect {
    return [polyline boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [polyline intersectsMapRect:mapRect];
}

- (MKMapPoint *) points {
    return [polyline points];
}


-(NSUInteger) pointCount {
    return [polyline pointCount];
}

- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range {
    return [polyline getCoordinates:coords range:range];
}@end
