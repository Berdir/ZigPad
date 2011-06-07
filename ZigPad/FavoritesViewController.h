//
//  Favorites.h
//  ZigPad
//
//  Created by ceesar on 4/13/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Param.h"
#import "LocalPicture.h"
#import "Database.h"
#import <CoreData/CoreData.h>
#import "QuartzCore/QuartzCore.h"
#import "Commander.h"
#import "AnimatorHelper.h"


@interface FavoritesViewController : UIViewController {
    
}

@property (nonatomic, retain) IBOutlet UIView *mySubview;
@property (nonatomic, retain) IBOutlet UILabel *favoritesLabel;
@property (nonatomic, assign) int startIndex;
@property (nonatomic, retain) NSArray* favorites; //favorite cache


@end
