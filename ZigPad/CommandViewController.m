    //
//  Detail.m
//  ZigPad
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "CommandViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Param.h"
#import "LocalPicture.h"

#import "Commander.h"

@implementation CommandViewController

@synthesize repeatToggle = _repeatToggle;



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
    Param *p = [self.presentation.activeAction getParamForKey:@"picture"];
    if (p != nil) {
        return [UIImage imageWithData:p.localPicture.picture];
    }
    return nil;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [self.imageButton setBackgroundImage:[self getCommandImage] forState:UIControlStateNormal];
    //[self.imageButton setBackgroundImage:[self getCommandImage]];
    
    self.imageButton.contentMode = UIViewContentModeScaleToFill;
    
    Param *p = [self.presentation.activeAction getParamForKey:@"stay"];
    // Show repeat icon if we can't press imagebutton to go next action
    // = if there's no stay param or the stay param is not 1.
    if (!p || ![p.value isEqualToString:@"1"]) {    
        self.repeatToggle.hidden = true;
    } else
        self.repeatToggle.hidden = false;
    
    [super viewDidLoad];

   
}



//called by button of commandview
- (void)click: (id) sender {
    
    [[Commander defaultCommander] sendAction:self.presentation.activeAction];
    
    [super click:sender];
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

- (void)dealloc {
    [_repeatToggle release];
    [super dealloc];
}


@end
