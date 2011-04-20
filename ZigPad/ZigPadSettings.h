//
//  ZigPadSettings.h
//  ZigPad
//
//  Created by ceesar on 19/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZigPadSettings : NSObject {
    @private NSUserDefaults *standardUserDefaults;
    
}

+(ZigPadSettings*) sharedInstance;

@property (readwrite,assign) BOOL simulationMode;
@property (readwrite,assign) NSString *configuratorURL;

@property (readonly,assign) UIColor *modeColor;

@property (readonly,assign) NSString *ip;
@property (readonly,assign) int port;

- (NSString *) modeKey: (BOOL) simulationMode;

-(void)setIP: (NSString *) ip simulationMode: (BOOL) simulationMode;
-(void)setPort: (int) ip simulationMode: (BOOL) simulationMode;


@end
