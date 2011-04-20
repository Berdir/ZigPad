    //
//  Detail.m
//  List
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommandViewController.h"
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>
#import "Param.h"
#import "LocalPicture.h"
#import "SequenceChoiceViewController.h"
#import "FavoritesViewController.h"
#import "Commander.h"

@implementation CommandViewController

@synthesize presentation;
@synthesize isMaster;

+(CommandViewController *) getViewControllerFromAction: (Action *) action {
    return [[CommandViewController alloc] initWithNibName:@"CommandView" bundle:[NSBundle mainBundle]];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Extract command image from action params.
- (UIImage *) getCommandImage {
    for (Param* p in self.presentation.activeAction.params) {
        if ([p.key isEqualToString:@"picture"]) {
            return [UIImage imageWithData:p.localImage.picture];
        }
    }
    return nil;
}

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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [imageButton setImage:[self getCommandImage] forState:UIControlStateNormal];
	
	label.text = self.presentation.activeSequence.name;
    actionLabel.text = self.presentation.activeAction.name;
    
    self.navigationController.toolbar.hidden = TRUE;
    self.navigationController.navigationBar.hidden = TRUE;
    
    [self initSwipeRecognizer];
    [super viewDidLoad];
}

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

- (void)click: (id) sender {
    self.isMaster = true;
    
    [[Commander defaultCommander] sendAction:self.presentation.activeAction];
    [self next:false];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) next:(BOOL) animated {
    Action *a = [self.presentation getNextAction];
    // Finished.
    if (a == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    CommandViewController *nextPage = [CommandViewController getViewControllerFromAction:a];
    
    nextPage.presentation = self.presentation;
    
    // Save NavigationController locally, to still have access to it in the second step.
    UINavigationController *navController = self.navigationController;
    
    // retain this viewcontroller, prevent dealloc.
    [[self retain] autorelease];
    
    // Pop the current controller and replace with another.
    [navController popViewControllerAnimated:NO];
    [navController pushViewController:nextPage animated:animated];
}

- (void) previous {
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
    
	[UIView beginAnimations: @"moveField" context: nil];
    	
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

- (void) registerNotificationCenter {
    
}
- (void) unregisterNotificationCenter {
    
}

- (void)dealloc {
	[label release];
    [super dealloc];
}


@end
