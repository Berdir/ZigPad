//
//  ActionViewController.h
//  ZigPad
//
//  Created by ceesar on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "SequenceChoiceViewController.h"
#import "FavoritesViewController.h"
#import "Action.h"
#import "Presentation.h"

@interface ActionViewController : UIViewController {
    IBOutlet UILabel *label;
    IBOutlet UILabel *actionLabel;
    IBOutlet UIButton *imageButton;
	
    @private Presentation *presentation;
    
    @private BOOL isMaster;
    
}

@property (readwrite, assign) Presentation *presentation;

@property (readwrite, assign) BOOL isMaster;

+(ActionViewController *) getViewControllerFromAction: (Action *) action;

- (void) next: (BOOL) animated;
- (void) previous;

- (IBAction) click: (id) sender;

- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser;

- (void) registerNotificationCenter;
- (void) unregisterNotificationCenter;

@end
