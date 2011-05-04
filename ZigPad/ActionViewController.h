//
//  ActionViewController.h
//  ZigPad
//
//  Created by ceesar on 4/27/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "SequenceChoiceViewController.h"
#import "FavoritesViewController.h"
#import "Action.h"
#import "Presentation.h"
#import "Param.h"

@interface ActionViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *actionLabel;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) Presentation *presentation;
@property (nonatomic) BOOL isMaster;

+(ActionViewController *) getViewControllerFromAction: (Action *) action;

- (void) next: (BOOL) animated;
- (void) previous;

- (IBAction) click: (id) sender;

- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser;

- (void) registerNotificationCenter;
- (void) unregisterNotificationCenter;

@end
