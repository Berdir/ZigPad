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
    [self next:false];
    
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
      
            UINavigationController* navCtrl = self.navigationController;
            
            [navCtrl popViewControllerAnimated:FALSE];
            [navCtrl pushViewController:chooser animated:YES];
            navCtrl.navigationBar.hidden = FALSE;
            
            [chooser release]; 
 
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:
        {	
            FavoritesViewController* favorite = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView" bundle:[NSBundle mainBundle]];
            
            [self.navigationController pushViewController:favorite animated:YES];
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



//Slides next ActionView to Window. If nextpage is nil then it only close actual view 
// XDirection: left = -1 or right = +1
- (void) slideWithAnimation:(int) XDirection: (ActionViewController*) nextPage: (bool) fullAnimated
{
    
    // Save NavigationController locally, to still have access to it in the next two steps.
    UINavigationController* navigationController = self.navigationController;

    
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
    
    CATransition *animation = [navigationController.view.layer animationForKey:@"SwitchToView1"];
    
    if (animation == nil)
    {
        animation = [CATransition animation];
        [animation setDuration:1.0];
        [animation setType:kCATransitionPush];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    }
    
    //define slide direction
    if (XDirection > 0)
        [animation setSubtype:kCATransitionFromLeft];
    else
        [animation setSubtype:kCATransitionFromRight];

    //sliede both views
    if (fullAnimated)
        [navigationController.view.layer addAnimation:animation forKey:@"SwitchToView1"];
    else
        //or just newer view
        [nextPage.view.layer addAnimation:animation forKey:@"SwitchToView1"];
    
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:nextPage animated:NO];

    
}

//slides the next Action to GUI
- (void) next:(BOOL) animated {
    Action *a = [self.presentation getNextAction];
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        //[self.navigationController popViewControllerAnimated:YES];
        [AnimatorHelper slideWithAnimation:-1 :self :nil :true];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    //by swipe
    if (animated) {[AnimatorHelper slideWithAnimation:-1 :self :nextPage:true];}
    //by klick
    else
    {
        [AnimatorHelper slideWithAnimation:-1 :self :nextPage:false];
        /*
        UINavigationController* navController = self.navigationController;
        [navController popViewControllerAnimated:NO];
        [navController pushViewController:nextPage animated:YES];
         */
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
        //[self.navigationController popViewControllerAnimated:YES];
        [AnimatorHelper slideWithAnimation:1 :self :nil :true];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    
    [AnimatorHelper slideWithAnimation:1 :self :nextPage:true];
}

 

@end
