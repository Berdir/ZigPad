//
//  ZigPadAppDelegate.h
//  ZigPad
//
//  Created by ceesar on 06/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZigPadAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
