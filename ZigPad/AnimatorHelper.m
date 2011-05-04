//
//  AnimatorHelper.m
//  ZigPad
//
//  Created by ceesar on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimatorHelper.h"


@implementation AnimatorHelper

//Slides next ActionView to Window. If nextpage is nil then it only close actual view 
// if actualpage is nil it only add a new slide
// XDirection: left = -1, right = +1, up = +2, down = -2
+ (void) slideWithAnimation:(int) direction:(UIViewController*) actualPage: (UIViewController*) nextPage: (bool) fullAnimated
{
    
    // Save NavigationController locally, to still have access to it in the next push/pop steps.
    UINavigationController* navigationController;
    if (actualPage!=nil)
        navigationController = actualPage.navigationController;
    else
        navigationController = actualPage.navigationController;
    
    //create animation (must be new created every methode call)
    CATransition*  animation = [CATransition animation];
    [animation setDuration:1.0];
    [animation setType:kCATransitionPush];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    
    //define a slide direction
    switch (direction) {
        case 1: [animation setSubtype:kCATransitionFromLeft]; break;
        case -1:[animation setSubtype:kCATransitionFromRight]; break;
        case 2:[animation setSubtype:kCATransitionFromBottom]; break;
        case -2:[animation setSubtype:kCATransitionFromTop]; break;          
        default:[animation setSubtype:kCATransitionFromLeft]; break;
    }
    
    if (fullAnimated)
    {
        //slide both views
        [navigationController.view.layer addAnimation:animation forKey:@"SwitchToView1"];
    }
    else
    {
        //slide just newer view or actual view
        if(nextPage!=nil)
        {
            [nextPage.view.layer addAnimation:animation forKey:@"SwitchToView1"];
        }
        else
        {
            [actualPage.view.layer addAnimation:animation forKey:@"SwitchToView1"];
        }
    }

    
    if (actualPage!=nil) [navigationController popViewControllerAnimated:NO];
    if (nextPage!=nil) [navigationController pushViewController:nextPage animated:NO];
    
    
    
    
    
    
    
    /* BITTE CODE LASSEN -> KNOWLEGEBASE
     [UIView animateWithDuration:0.5
     animations:^{ 
     
     //shift old slide outside animated
     navigationController.view.transform = CGAffineTransformMakeTranslation(XDirection * 320,0);
     } 
     completion:^(BOOL finished){
     //remove old slide                         
     [navigationController popViewControllerAnimated:NO];
     
     if (nextPage != nil)
     {
     //add new slide if avaiable
     [navigationController pushViewController:nextPage animated:NO];                        
     //shift new slide to startposition outside window
     navigationController.view.transform = CGAffineTransformMakeTranslation(-XDirection * 320,0);
     
     [UIView animateWithDuration:0.5
     animations:^{ 
     
     //shift new slide inside window animated
     navigationController.view.transform = CGAffineTransformMakeTranslation(0,0);
     
     } 
     completion:^(BOOL finished){
     ;
     }];
     }
     
     }];
     
     */
    
}


@end
