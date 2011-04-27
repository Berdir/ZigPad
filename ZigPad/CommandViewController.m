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

#import "Commander.h"

@implementation CommandViewController



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
            return [UIImage imageWithData:p.localPicture.picture];
        }
    }
    return nil;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [imageButton setImage:[self getCommandImage] forState:UIControlStateNormal];

    [super viewDidLoad];
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





- (void) registerNotificationCenter {
    
}
- (void) unregisterNotificationCenter {
    
}

- (void)dealloc {
	[label release];
    [super dealloc];
}


@end
