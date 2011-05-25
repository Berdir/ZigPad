//
//  VideoViewController.h
//  ZigPad
//
//  Created by ceesar on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface VideoViewController : ActionViewController {
    MPMoviePlayerController *moviePlayer;
}

@end
