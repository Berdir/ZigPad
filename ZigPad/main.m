//
//  main.m
//  ZigPad
//
//  Created by ceesar on 06/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commander.h"
#import "Database.h"
#import "ZigPadSettings.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    //flush all singeltons
    [[Commander defaultCommander] release];
    [[Database sharedInstance]release];
    
    [pool release];
    return retVal;
}
