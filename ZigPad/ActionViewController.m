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

-(void) foo
{
    // Save NavigationController locally, to still have access to it in the next two steps.
    UINavigationController* navigationController = self.navigationController;

    self.navigationController.view.transform = CGAffineTransformMakeTranslation(-100,0);
    //[navigationController popViewControllerAnimated:NO];
    
    //[navigationController pushViewController:nextPage animated:NO];
}

//Slides next ActionView to Window. If nextpage is nil then it only close actual view 
// XDirection: left = -1 or right = +1
- (void) slideWithAnimation:(int) XDirection: (ActionViewController*) nextPage
{

    
    //shift view out of window
    [UIView beginAnimations:nil context: nil];    
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDuration:	1.0];
    [UIView setAnimationDidStopSelector:@selector(foo)];
    self.navigationController.view.transform = CGAffineTransformMakeTranslation(XDirection * 100,0);
    
    
    [UIView commitAnimations];
    
    //close actual view

    
    /*
    
    [UIView beginAnimations:nil context: nil];    
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDuration:	1.0];
    navigationController.view.transform = CGAffineTransformMakeTranslation(XDirection * 0,0);
    [UIView commitAnimations];
     */
    
}

- (void) next:(BOOL) animated {
    Action *a = [self.presentation getNextAction];
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;



    [self slideWithAnimation:1 :nextPage];


    //self.view.transform = CGAffineTransformMakeTranslation(100,0);
    //nextPage.view.transform = CGAffineTransformMakeTranslation(-320,0);
    
    

    
    

    
    

    
    
    //[navigationController popViewControllerAnimated:NO];
    
    //[navigationController pushViewController:nextPage animated:NO];
    

    
    
    


}

- (void) previous
{
    /*
    Action *a = [self.presentation getPreviousAction];
    // Finished.
    if (a == nil) {
        self.navigationController.navigationBar.hidden = FALSE;
        self.navigationController.toolbar.hidden = FALSE;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.presentation;
    
    // Save NavigationController locally, to still have access to it in the next two steps.
    UINavigationController* navigationController = self.navigationController;
    
    [UIView beginAnimations:nil context: nil];
    [navigationController popViewControllerAnimated:NO];
    [navigationController pushViewController:nextPage animated:NO];
     */
    //[self _previous];
}


- (void) _previous {
    // Init animation
    
    CommandViewController *nextPage = [CommandViewController getViewControllerFromAction:[self.presentation getNextAction]];
    
    // Finished.
    if (nextPage == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    // retain this viewcontroller, prevent dealloc.
    [[self retain] autorelease];
    
    // Save NavigationController locally, to still have access to it in the second step.
    UINavigationController *navController = self.navigationController;
    
	[UIView beginAnimations:@"move" context: nil];
    
	[UIView setAnimationDelegate: self];
    
	[UIView setAnimationDuration:	.5];
    
    // For left to right transition animation
	//[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:navController.view	 cache:NO];	
    
    self.view.transform = CGAffineTransformMakeTranslation(320,0);
    nextPage.view.transform = CGAffineTransformMakeTranslation(320,0);
	
    // Pop the current controller and replace with another.
    [navController popViewControllerAnimated:NO];
    [navController pushViewController:nextPage animated:NO];
    
    [UIView commitAnimations];
}
 

@end
