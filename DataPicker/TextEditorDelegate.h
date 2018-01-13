//
//  TextEditorDelegate.h
//  Sunshire Driver Work Log
//
//  Created by 姚远 on 8/3/16.
//  Copyright © 2016 Sunshireshuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TextEditorDelegate <NSObject>
-(void) didSaveTextForKey:(NSString *) key
                  andText:(NSString *) value;
-(void) didCancelTextSelectingForKey:(NSString *) key;

@end
