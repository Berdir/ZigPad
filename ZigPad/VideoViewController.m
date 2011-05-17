//
//  VideoViewController.m
//  ZigPad
//
//  Created by ceesar on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"


@implementation VideoViewController

@synthesize myWebView = _myWebView;

bool clickWasFirstTime = false;



- (void)dealloc
{
    [_myWebView release];
    clickWasFirstTime = false; //because Memorymanager makes recycling of deallocated objects
    [super dealloc];
}

//called by button of VideoView
- (void)click: (id) sender {
    
    //go next action
    if (clickWasFirstTime)
        [super click:sender];
    else
    {
        //play the movie
        //NSString* urlAddress = @"http://user.enterpriselab.ch/~tazimmer/kungfupigeon5.mov";
        
        Param* urlParam = [self.presentation.activeAction getParamForKey:@"url"];
        NSString* urlAddress = urlParam.value;
        
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //Load the request in the UIWebView.
        [self.myWebView loadRequest:requestObj];
        
        clickWasFirstTime = TRUE;
        
    }
    
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //get a button image if avaiable
    UIImage* img = nil;
    Param* localPicture = [self.presentation.activeAction getParamForKey:@"picture"];
    if (localPicture !=nil)
        img = [UIImage imageWithData:localPicture.localPicture.picture];
    
        //fill button with image....
    if (img !=nil)
        [self.imageButton setImage:img forState:UIControlStateNormal];
    else
        //or just a Letter
        [self.imageButton setTitle:@"for Video Stream: \n click me!" forState:UIControlStateNormal];
 
}

//generated code....

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
