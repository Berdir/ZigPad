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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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

- (void)flowCover:(FlowCoverView *)view didSelect:(int)image
{
    [self.presentation jumpToSequence: image];
    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:self.presentation.activeAction];
    nextPage.presentation = self.presentation;
    
    [[Commander defaultCommander] sendString:self.presentation.activeSequence.command];

    [AnimatorHelper slideWithAnimation:2 :self :nextPage :false:true:true];
    
    
    SyncEvent *event = [[SyncEvent alloc] init];
    event.command = JUMP;
    event.direction = UP;
    event.argument_upperByte = self.presentation.currentSequenceIndex;
    event.argument_lowerByte = self.presentation.currentActionIndex;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncFire" object:event];
    [event release];
}


@end
