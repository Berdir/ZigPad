//
//  WebCamViewController.m
//  ZigPad
//
//  Created by ceesar on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebCamViewController.h"
#import "Database.h"


@implementation WebCamViewController

@synthesize myWebView = _myWebView;


// Extract url link from action params.
- (NSString *) getURLfromParams {
    for (Param* p in self.presentation.activeAction.params) {
        if ([p.key isEqualToString:@"url"]) {
            return p.value;
        }
    }
    return @"about:blank";
}

//TODO: bitte bald löschen
-(void) dummyInit
{
    self.navigationController.navigationBar.hidden = FALSE;
    
    // set active action from local xml

    NSManagedObjectContext* context =  [[Database sharedInstance] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    NSError* error = nil;
  
    NSEntityDescription *entityDescriptionPres = [NSEntityDescription entityForName:@"Presentation" inManagedObjectContext:context];
    [request setEntity:entityDescriptionPres];    
    NSArray *presentations = [context executeFetchRequest:request error:&error]; 
    
    Presentation* p = [presentations objectAtIndex:0];
    
    self.presentation = p;
    
    NSEntityDescription *entityDescriptionAct = [NSEntityDescription entityForName:@"Action" inManagedObjectContext:context];
    [request setEntity:entityDescriptionAct];    
    NSArray *actions = [context executeFetchRequest:request error:&error]; 
    
    for (Action* a in actions) {
        if ([a.name isEqualToString:@"Webcam"])
        {
            self.presentation.activeAction = a;
        }
    }
    
    NSEntityDescription *entityDescriptionSeq = [NSEntityDescription entityForName:@"Sequence" inManagedObjectContext:context];
    [request setEntity:entityDescriptionSeq];    
    NSArray *sequences = [context executeFetchRequest:request error:&error]; 
    
    Sequence* s = [sequences objectAtIndex:0];
    self.presentation.activeSequence = s;
    

    [request release];

    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.


    //NSString * urlAddress = @"http://www.stefanbion.de/cgi-bin/webcam_bsp_cac_cnt_mjp.pl?format=mjpeg";
    //NSString* urlAddress = @"http://user.enterpriselab.ch/~tazimmer/kungfupigeon5.mov";
    
    [self dummyInit];
    
    NSString* urlAddress = [self getURLfromParams];
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.myWebView loadRequest:requestObj];

    
    
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
