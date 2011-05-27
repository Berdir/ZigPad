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
#import "SyncEvent.h"

/**
 * Base view controller for all actions.
 *
 * Extend this class when creating a new action controller and override the
 * default implementations as appropriate.
 */
@interface ActionViewController : UIViewController {

}

/**
 * Reference to the label that displays the current sequence.
 */
@property (nonatomic, retain) IBOutlet UILabel *label;

/**
 * Reference to the label that displays the current action name.
 */
@property (nonatomic, retain) IBOutlet UILabel *actionLabel;

/*
 * References the button that generates the click event.
 */
@property (nonatomic, retain) IBOutlet UIButton *imageButton;

/**
 * The active presentation instance.
 */
@property (nonatomic, retain) Presentation *presentation;

/**
 * A flag to indicate if this is the currently active device.
 *
 * Active means in this case that it is directly controlled through the UI as
 * opposed to synchronization events..
 */
@property (nonatomic) BOOL isMaster;

/**
 * Helper method that initiates the view controller for a given action.
 *
 * @param action The action for which the view controller should be created.
 *
 * @return A child-class of ActionViewController.
 */
+(ActionViewController *) getViewControllerFromAction: (Action *) action;

/**
 * Switch to the next action in the current presentation.
 *
 * @param animated If the switch should be animated (swipe) or not (click).
 */
- (void) next: (BOOL) animated;

/**
 * Switch to the previous action in the current presentation.
 */
- (void) previous;

/**
 * Click callback for the image button.
 *
 * @param sender Indicates the button that is executing this action.
 */
- (IBAction) click: (id) sender;

/**
 * Callback to handle swipe events.
 *
 * @param recogniser Instance of the swipe recognizer instance.
 */
- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser;

/**
 * Register for sync events through the notification center.
 */
- (void) registerNotificationCenter;

/**
 * Unregister for sync events through the notification center.
 */
- (void) unregisterNotificationCenter;

/**
 * Send a sync event.
 *
 * This sends a sync notification event for the currently active action.
 *
 * @param direction Indicates the animation direction of the connected devices.
 */
- (void) fireSyncEvent: (SyncEventSwipeDirection) direction;

@end
