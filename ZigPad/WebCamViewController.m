//
//  WebCamViewController.m
//  ZigPad
//
//  Created by ceesar on 4/26/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "WebcamViewController.h"
#import "Database.h"


@implementation WebcamViewController

@synthesize myWebView = _myWebView;


// Extract url link from action params.
- (NSString *) getURLfromParams {
    Param *p = [self.presentation.activeAction getParamForKey:@"url"];
    if (p != nil) {
        return p.value;
    }
    return @"about:blank";
}



- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.


    //NSString * urlAddress = @"http://www.stefanbion.de/cgi-bin/webcam_bsp_cac_cnt_mjp.pl?format=mjpeg";
    //NSString* urlAddress = @"http://user.enterpriselab.ch/~tazimmer/kungfupigeon5.mov";
    
    NSString* urlAddress = [self getURLfromParams];
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.myWebView loadRequest:requestObj];

    
    [super viewDidLoad];    
    
}

- (void)dealloc
{
    if (_myWebView != nil && [_myWebView retainCount] > 0) [_myWebView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [_myWebView release];
    [super viewDidUnload];
}


//generated Code..

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

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
