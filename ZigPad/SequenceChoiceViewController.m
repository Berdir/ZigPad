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


@implementation SequenceChoiceViewController

Presentation *presentation;

//caches all Sequence UIImages from the current Presentation
-(void) initWithPresentation:(Presentation*) p
{
    presentation = p;
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








/************************************************************************/
/*																		*/
/*	FlowCover Callbacks													*/
/*																		*/
/************************************************************************/

- (int)flowCoverNumberImages:(FlowCoverView *)view
{
    return[presentation.orderedSequences count];
}

- (UIImage *)flowCover:(FlowCoverView *)view cover:(int)image
{
    Sequence *s = (Sequence *) [presentation.orderedSequences objectAtIndex:image];
    
    return [UIImage imageWithData:s.icon.picture];       
}

- (void)flowCover:(FlowCoverView *)view didSelect:(int)image
{
    [presentation jumpToSequence: image];
    
    [self.navigationController popViewControllerAnimated:true];
}


@end
