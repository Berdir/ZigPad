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

    Action* a = self.presentation.activeAction;
    Param* p = nil;
    NSData* data = nil;
    
    //load online picture
    p = [a getParamForKey:@"url"];
    if (p != nil) {
        NSString* urlAddress = p.value;
        data = [ImageDownloader downloadImage:urlAddress];
    }
    
    //if no online pic configured then load from local db
    else
    {
        p = [a getParamForKey:@"picture"];
        if (p != nil)
            data = p.localPicture.picture;
    }
    
    //if image successfully loaded
    if ([data length] > 0)
    {
        //put data into UIImage
        UIImage* image =  [UIImage imageWithData:data];
        [self.myImageView setImage:image];
        
        //hide Labels because not used this case
        self.label.hidden = true;
        self.actionLabel.hidden = true;
    }
    
    //otherwise: shit happens..
    
    
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
