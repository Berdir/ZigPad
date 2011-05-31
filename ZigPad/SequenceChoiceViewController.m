//
//  FlowCoverViewController.m
//  FlowCover
//
//  Created by William Woody on 12/13/08.
//  Copyright CEESAR 2008. All rights reserved.
//

#import "SequenceChoiceViewController.h"
#import <CoreData/CoreData.h>
#import "Database.h"
#import "Presentation.h"
#import "Sequence.h"
#import "LocalPicture.h"
#import "ActionViewController.h"
#import "AnimatorHelper.h"
#import "SyncEvent.h"


@implementation SequenceChoiceViewController

@synthesize presentation = _presentation;
@synthesize label = _label;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        // Custom initialization 
        
    }
    return self;
}
 */


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

//remake last action and pop to navigationcontroller
-(void) navigateBackToActions:(UISwipeGestureRecognizer *) recogniser
{
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:self.presentation.activeAction];
    nextPage.presentation = self.presentation;
    nextPage.isMaster = TRUE;

    [AnimatorHelper slideWithAnimation:2 :self :nextPage :true:true:true];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    //init a swipe listener
    UISwipeGestureRecognizer* recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(navigateBackToActions:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:recognicer];
    [recognicer release];
    
    //show the current sequence on view
    ((FlowCoverView*) self.view).offset = self.presentation.currentSequenceIndex;
    self.label.text = self.presentation.activeSequence.name; 
    
}


// Show navigation and toolbar when the view appears.
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.navigationController.navigationBar.topItem.title = @"Sequences";

    [super viewWillAppear:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}


-(void) dealloc
{
    [_presentation release];
    [_label release];
    [super dealloc];
}





/************************************************************************/
/*																		*/
/*	FlowCover Callbacks													*/
/*																		*/
/************************************************************************/

- (int)flowCoverNumberImages:(FlowCoverView *)view
{
    return[self.presentation.sequences count];
}

- (UIImage *)flowCover:(FlowCoverView *)view cover:(int)image
{
    Sequence *s = (Sequence *) [self.presentation.orderedSequences objectAtIndex:image];
    
    return [UIImage imageWithData:s.icon.picture];       
}

- (void)flowCover:(FlowCoverView *)view highlighted:(int)cover {
    self.label.text = ((Sequence *)[self.presentation.orderedSequences objectAtIndex:cover]).name;
}

- (void)flowCover:(FlowCoverView *)view didSelect:(int)image
{
    //Send an exit command to uninitialize current sequence
    if (self.presentation.activeSequence.command !=nil)
    {
        NSString* exitCommand = [NSString stringWithFormat:@"%@_EXIT",self.presentation.activeSequence.command];
        [[Commander defaultCommander] sendString:exitCommand];
    }
    
    //goto chosen sequence and first action of it
    [self.presentation jumpToSequence: image];
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:self.presentation.activeAction];
    nextPage.presentation = self.presentation;
    
    //Send an init command to initialize next sequence
    if (self.presentation.activeSequence.command !=nil)
    {

        NSString* initCommand = [NSString stringWithFormat:@"%@_INIT",self.presentation.activeSequence.command];
        [[Commander defaultCommander] sendString:initCommand];
    }

    [AnimatorHelper slideWithAnimation:2 :self :nextPage :false:true:true];
    
    
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = JUMP;
    event.direction = UP;
    event.argument_upperByte = self.presentation.currentSequenceIndex;
    event.argument_lowerByte = self.presentation.currentActionIndex;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncFire" object:event];
    [event release];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
