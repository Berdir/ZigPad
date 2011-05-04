//
//  ImageViewController.m
//  ZigPad
//
//  Created by ceesar on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"


@implementation ImageViewController

@synthesize myImageView = _myImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_myImageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    Action* a = self.presentation.activeAction;
    Param* p = nil;
    
    //try to load online picture
    p = [a getParamForKey:@"url"];
    if (p != nil) {
        NSString* urlAddress = p.value;
        
        NSData* data = [ImageDownloader downloadImage:urlAddress];
        //put data into UIImage
        UIImage* image =  [UIImage imageWithData:data];
        [self.myImageView setImage:image];
        
        //everything is ok now finish
        return;
    }
    
    //if nothing found try to load a pic from local db
    p = [a getParamForKey:@"picture"];
    if (p != nil) {
        
        UIImage* image =  [UIImage imageWithData:p.localPicture.picture];
        [self.myImageView setImage:image];
    } 
    //if still nothing then shit happens..
    
    
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
