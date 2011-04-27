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


@implementation ActionViewController

@synthesize presentation;
@synthesize isMaster;

// Returns a suitable controller plugin for that Action.
+(ActionViewController *) getViewControllerFromAction: (Action *) action 
{
    
    NSString *viewName = [NSString stringWithFormat:@"%@View", [action.type capitalizedString]];
    NSString *controllerName = [NSString stringWithFormat:@"%@Controller", viewName];
    
    NSLog(@"Loading %@ with view '%@'", controllerName, viewName); 
    
    @try {
        ActionViewController* suitableController = [[NSClassFromString(controllerName) alloc] 
                                                initWithNibName:viewName 
                                                bundle:[NSBundle mainBundle]];
        [viewName release];
        [controllerName release];
        return [suitableController autorelease]; //don't make Memory-Zombies
    } @catch (NSException *exception) {
        [viewName release];
        [controllerName release];
        NSLog(@"Failed to initalize ViewController: %@", exception);
    }
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
    label.text = self.presentation.activeSequence.name;
    actionLabel.text = self.presentation.activeAction.name;
    
    self.navigationController.toolbar.hidden = TRUE;
    self.navigationController.navigationBar.hidden = TRUE;
    
    [self initSwipeRecognizer];
    [super viewDidLoad];
}

-(void) dealloc
{
    if (label !=nil && [label retainCount] > 0) [label release];
	if (imageButton !=nil && [imageButton retainCount] > 0)[imageButton release];
    if (actionLabel !=nil && [actionLabel retainCount] > 0)[actionLabel release];
    if (presentation !=nil && [presentation retainCount] > 0)[presentation release];
}

//common implementation for each Action plugin from fired swipe event 
- (void) handleSwipeFrom: (UISwipeGestureRecognizer *) recogniser {	
    switch (recogniser.direction) {
        case UISwipeGestureRecognizerDirectionDown:
        {
            SequenceChoiceViewController* chooser = [[SequenceChoiceViewController alloc] initWithNibName:@"SequenceChoiceView" bundle:[NSBundle mainBundle]];
            
            [chooser initWithPresentation: self.presentation]; 
            
            [self.navigationController pushViewController:chooser animated:YES];
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
- (void) slideWithAnimation:(int) XDirection: (ActionViewController*) nextPage
{
    
    // Save NavigationController locally, to still have access to it in the next two steps.
    UINavigationController* navigationController = self.navigationController;

    
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

    
}

//slides the next Action to GUI
- (void) next:(BOOL) animated {
    Action *a = [self.presentation getNextAction];
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;


    if (animated) {[self slideWithAnimation:-1 :nextPage];}
    else
    {
        UINavigationController* navController = self.navigationController;
        [navController popViewControllerAnimated:NO];
        [navController pushViewController:nextPage animated:YES];
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
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    
    [self slideWithAnimation:1 :nextPage];
}

 

@end
