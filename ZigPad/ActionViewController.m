//
//  ActionViewController.m
//  ZigPad
//
//  Created by Markus Zimmermann on 4/27/11.
//  Copyright 2011 ceesar. All rights reserved.
//

#import "ActionViewController.h"
#import "CommandViewController.h"
#import "WebcamViewController.h"
#import "AnimatorHelper.h"
#import "SyncEvent.h"

@implementation ActionViewController

@synthesize label = _label;
@synthesize actionLabel = _actionLabel;
@synthesize imageButton = _imageButton;
@synthesize presentation = _presentation;
@synthesize isMaster = _ismaster;

// Returns a suitable controller plugin for that Action.
+(ActionViewController *) getViewControllerFromAction: (Action *) action 
{
    
    NSString *viewName = [NSString stringWithFormat:@"%@View", [action.type capitalizedString]];
    NSString *controllerName = [NSString stringWithFormat:@"%@Controller", viewName];

    ActionViewController* suitableController = [[NSClassFromString(controllerName) alloc] 
                                                initWithNibName:viewName 
                                                bundle:[NSBundle mainBundle]];
        return [suitableController autorelease]; //don't make Memory-Zombies
    return nil;
    
}

- (void) registerNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSyncEvent:) 
                                                 name:@"ZigPadSyncReceive"
                                               object:nil];
}

- (void) unregisterNotificationCenter {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveSyncEvent: (NSNotification *) notification {
    SyncEvent *event = [notification object];
    
    self.isMaster = false;
    
    if (event.command == JUMP) {
        Action *a = [self.presentation jumpToAction:event.argument_lowerByte sequenceIndex:event.argument_upperByte];
        
        // Finished.
        if (a == nil) {
            self.navigationController.navigationBar.hidden = FALSE;
            self.navigationController.toolbar.hidden = FALSE;
            [AnimatorHelper slideWithAnimation:-1 :self :nil :true:false:true];
            return;
        }
        
        ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
        nextPage.presentation = self.presentation;
        
        switch (event.direction) {
            case LEFT:
                [AnimatorHelper slideWithAnimation:1 :self :nextPage :false :true :true];
                break;
            case LEFT_ANIMATED:
                [AnimatorHelper slideWithAnimation:1 :self :nextPage :true :true :true];
                break;
            case RIGHT:
                [AnimatorHelper slideWithAnimation:-1 :self :nextPage :false :true :true];
                break;
            case RIGHT_ANIMATED:
                [AnimatorHelper slideWithAnimation:-1 :self :nextPage :true :true :true];
                break;
        }
    }
}

- (void) fireSyncEvent: (SyncEventSwipeDirection) direction {
    if (self.isMaster) {
        SyncEvent *event = [[SyncEvent alloc] init];
        event.command = JUMP;
        event.direction = direction;
        event.argument_upperByte = self.presentation.currentSequenceIndex;
        event.argument_lowerByte = self.presentation.currentActionIndex;
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncFire" object:event];
        [event release];
    }
}

//event is fired when button on any subclass of actionViewController is pressed
//note: click is mostly called by overwritten method of subclass
- (void)click: (id) sender {
    self.isMaster = true;
    
    Param *p = [self.presentation.activeAction getParamForKey:@"stay"];
    
    // Only continue to the next action if there is no stay param or the stay
    // param is not 1.
    if (!p || ![p.value isEqualToString:@"1"]) {    
        [self next:false];
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); 
}

//set Finger-Swipe Listener
- (void) initSwipeRecognizer {
    UISwipeGestureRecognizer *recognicer;
    
    recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipeFrom:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:recognicer];
    [recognicer release];
    
    recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipeFrom:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:recognicer];
    [recognicer release];
    
    recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipeFrom:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:recognicer];
    [recognicer release];
    
    recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipeFrom:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self view] addGestureRecognizer:recognicer];
    [recognicer release];
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.label.text = self.presentation.activeSequence.name;
    self.actionLabel.text = self.presentation.activeAction.name;

    NSLog(@"geladen: Sequenz %@ mit ID %@  Action %@ mit ID %@",self.presentation.activeSequence.name, self.presentation.activeSequence.refId, self.presentation.activeAction.name, self.presentation.activeAction.refId);

    self.navigationController.toolbar.hidden = TRUE;
    self.navigationController.navigationBar.hidden = TRUE;
    
    [self registerNotificationCenter];
    
    [self initSwipeRecognizer];
    
}

-(void) dealloc
{
    [self unregisterNotificationCenter];
    [_label release];
    [_actionLabel release];
    [_imageButton release];
    [_presentation release];
    [super dealloc];
}

//common implementation for each Action plugin from fired swipe event 
- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser {	
    
    self.isMaster = true;
    
    switch (recogniser.direction) {
        case UISwipeGestureRecognizerDirectionDown:
        {
            SequenceChoiceViewController* chooser = [[SequenceChoiceViewController alloc] initWithNibName:@"SequenceChoiceView" bundle:[NSBundle mainBundle]];
            
            chooser.presentation = self.presentation; 
            
            self.navigationController.navigationBar.hidden = FALSE;
            [AnimatorHelper slideWithAnimation:-2 :self :chooser :false:true:true];
            
            
            [chooser release]; 
 
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:
        {	
            FavoritesViewController* favorite = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView" bundle:[NSBundle mainBundle]];
            
            [AnimatorHelper slideWithAnimation:2 :self :favorite :false:true:false];
            [favorite release]; 
            break;   
        }
        case UISwipeGestureRecognizerDirectionRight:
            [self previous];	
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [self next:TRUE];
            break;
            
        default:
            break;
    }
}



//slides the next Action to GUI
- (void) next:(BOOL) animated {
    Action *a = [self.presentation getNextAction];
    
    
    [self fireSyncEvent:animated ? RIGHT_ANIMATED : RIGHT];
    
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [AnimatorHelper slideWithAnimation:-1 :self :nil :true:false:true];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    //by swipe
    if (animated) {[AnimatorHelper slideWithAnimation:-1 :self :nextPage:true:true:true];}
    //by klick
    else
    {
        [AnimatorHelper slideWithAnimation:-1 :self :nextPage:false:true:true];

    }
    
    


}

//Slides the previous Action to GUI
- (void) previous
{
    Action *a = [self.presentation getPreviousAction];
    
    [self fireSyncEvent: LEFT];
    
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [AnimatorHelper slideWithAnimation:1 :self :nil :true:false:true];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    
    [AnimatorHelper slideWithAnimation:1 :self :nextPage:true:true:true];
}

 

@end
