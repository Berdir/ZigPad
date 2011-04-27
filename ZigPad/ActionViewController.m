//
//  ActionViewController.m
//  ZigPad
//
//  Created by Markus Zimmermann on 4/27/11.
//  Copyright 2011 ceesar. All rights reserved.
//

#import "ActionViewController.h"
#import "CommandViewController.h"


@implementation ActionViewController

@synthesize presentation;
@synthesize isMaster;

//returns a suitable controller plugin for that Action
+(ActionViewController *) getViewControllerFromAction: (Action *) action 
{
    //TODO: Logik für das passende Plugin einbauen
    ActionViewController* suitableController = [[CommandViewController alloc] 
                                                initWithNibName:@"CommandView" 
                                                bundle:[NSBundle mainBundle]];
    return [suitableController autorelease]; //don't make Memory-Zombies
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
