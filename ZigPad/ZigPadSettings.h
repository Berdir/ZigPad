//
//  ZigPadSettings.h
//  ZigPad
//
//  Created by ceesar on 19/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Allows to access and store application settings.
 *
 * Uses NSUserDefaults to store these permanently.
 */
@interface ZigPadSettings : NSObject {
    /**
     * NSUserDefaults instance.
     */
    @private NSUserDefaults *standardUserDefaults;
    
}

/**
 * Returns the shared instance of this class.
 */
+(ZigPadSettings*) sharedInstance;

/**
 * Setting for the SimulationMode, YES if on.
 */
@property (readwrite,assign) BOOL simulationMode;

/**
 * Setting for the configurator URL.
 */
@property (readwrite,assign) NSString *configuratorURL;

/**
 * Returns the UIColor instance for the navigationBar.
 */
@property (readonly,assign) UIColor *modeColor;

/**
 * Setting for the HomeServer IP, depends on the simulation mode.
 */
@property (readonly,assign) NSString *ip;

/**
 * Setting for the HomeServer Port, depends on the simulation mode.
 */
@property (readonly,assign) int port;

/**
 * Allows to set the IP for a specific simulation mode.
 *
 * @param ip The IP to be used for this simulation mode.
 * @param simulationMode YES if this IP is for the simulation mode.
 */
-(void)setIP: (NSString *) ip simulationMode: (BOOL) simulationMode;

/**
 * Allows to set the Port for a specific simulation mode.
 *
 * @param ip The Port to be used for this simulation mode.
 * @param simulationMode YES if this Port is for the simulation mode.
 */
-(void)setPort: (int) port simulationMode: (BOOL) simulationMode;


@end
