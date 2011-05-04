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

//event is fired when button on any subclass of actionViewController is pressed
//note: click is mostly called by overwritten method of subclass
- (void)click: (id) sender {
    self.isMaster = true;
    
    Param *p = [self.presentation.activeAction getParamForKey:@"stay"];
    
    NSLog(@"%@", p);
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
    
    [self initSwipeRecognizer];
    
}

-(void) dealloc
{
    [_label release];
    [_actionLabel release];
    [_imageButton release];
    [_presentation release];
    [super dealloc];
}

//common implementation for each Action plugin from fired swipe event 
- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser {	
    switch (recogniser.direction) {
        case UISwipeGestureRecognizerDirectionDown:
        {
            SequenceChoiceViewController* chooser = [[SequenceChoiceViewController alloc] initWithNibName:@"SequenceChoiceView" bundle:[NSBundle mainBundle]];
            
            [chooser initWithPresentation: self.presentation]; 
            
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
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [AnimatorHelper slideWithAnimation:-1 :self :nil :false:false:true];
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
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [AnimatorHelper slideWithAnimation:1 :self :nil :false:false:true];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    
    [AnimatorHelper slideWithAnimation:1 :self :nextPage:true:true:true];
}

 

@end
