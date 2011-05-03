//
//  FlowCoverViewController.m
//  FlowCover
//
//  Created by William Woody on 12/13/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "SequenceChoiceViewController.h"
#import <CoreData/CoreData.h>
#import "Database.h"
#import "Presentation.h"
#import "Sequence.h"
#import "LocalPicture.h"
#import "ActionViewController.h"


@implementation SequenceChoiceViewController

@synthesize presentation = _presentation;

//caches all Sequence UIImages from the current Presentation
-(void) initWithPresentation:(Presentation*) p
{
    self.presentation = p;
}

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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
			(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
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
    
    UINavigationController* navCtrl = self.navigationController;
    
    navCtrl.navigationBar.hidden = TRUE;
    
    // Remove the current viewController and the currently active ActionViewController
    // below it.
    [navCtrl popViewControllerAnimated:FALSE];
    [navCtrl popViewControllerAnimated:FALSE];
    
    [navCtrl pushViewController:nextPage animated:TRUE];
    
}


@end
