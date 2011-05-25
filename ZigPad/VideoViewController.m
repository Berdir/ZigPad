//
//  VideoViewController.m
//  ZigPad
//
//  Created by ceesar on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"


@implementation VideoViewController

bool movieIsPlaying = false;

- (void)dealloc
{
    // Stop and release movie player if necessary.
    if (moviePlayer) {
        [moviePlayer stop];
        [moviePlayer release];
        moviePlayer = nil;
    }
    movieIsPlaying = false; //because Memorymanager makes recycling of deallocated objects
    [super dealloc];
}

//called by button of VideoView
- (void)click: (id) sender {
    
    // Check if the vide is already playing.
    if (movieIsPlaying) {
        // Stop and release movie player if necessary.
        if (moviePlayer) {
            [moviePlayer stop];
            [moviePlayer release];
            moviePlayer = nil;
        }

        // Switch back to normal grey status bar.
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [super click:sender];
    } else
    {
        
        //play the movie
        //NSString* urlAddress = @"http://user.enterpriselab.ch/~tazimmer/kungfupigeon5.mov";
        
        Param* urlParam = [self.presentation.activeAction getParamForKey:@"url"];
        
        // Initalize and start the movie player with the video URL.
        NSURL* videoURL = [NSURL URLWithString:urlParam.value];
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        [moviePlayer prepareToPlay];
        [moviePlayer play];
        
        // Set size and autoresizing flags of the movie player view.
        [moviePlayer.view setFrame: self.view.frame];
        moviePlayer.view.backgroundColor = [UIColor grayColor];
        moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Display movie player view below button.
        [self.view insertSubview:moviePlayer.view belowSubview:self.imageButton];
        
        // Make the button invincible
        [self.imageButton setImage:nil forState:UIControlStateNormal];
        [self.imageButton setBackgroundColor: [UIColor clearColor]];
        
        // Make the status bar dark to be less intrusive.
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];

        // Set the movie is playing flag, next button click goes to next action.
        movieIsPlaying = TRUE;        
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
        //[self.imageButton setTitle:@"for Video Stream: \n click me!" forState:UIControlStateNormal];
        //or just a play Button
        img = [UIImage imageNamed:@"play.jpg"];
        [self.imageButton setImage:img forState:UIControlStateNormal];
 
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
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



@end
