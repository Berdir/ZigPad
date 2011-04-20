//
//  Detail.h
//  List
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Presentation.h"


@interface CommandViewController : UIViewController {
	IBOutlet UILabel *label;
	IBOutlet UIButton *button;
    IBOutlet UIButton *imageButton;
    IBOutlet UILabel *actionLabel;
	
	@private Presentation *presentation;
    @private Action *action;
    
    @private BOOL isMaster;
}

@property (readwrite, assign) Presentation *presentation;

@property (readwrite, assign) BOOL isMaster;

+(CommandViewController *) getViewControllerFromAction: (Action *) action;

- (void) next: (BOOL) animated;
- (void) previous;

- (IBAction) click: (id) sender;

- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser;

- (void) registerNotificationCenter;
- (void) unregisterNotificationCenter;



@end
