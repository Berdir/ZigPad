//
//  AnimatorHelper.h
//  ZigPad
//
//  Created by ceesar on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface AnimatorHelper : NSObject {
    
}
//Slides next ActionView to Window. If nextpage is nil then it only close actual view 
// if actualpage is nil it only add a new slide
// XDirection: left = -1, right = +1, up = +2, down = -2
+ (void) slideWithAnimation:(int) direction:(UIViewController*) actualPage: (UIViewController*) nextPage: (bool) fullAnimated: (bool)pushOnStack: (bool) popOnStack;

@end
