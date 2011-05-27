//
//  ZigPadSettings.m
//  ZigPad
//
//  Created by ceesar on 19/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "ZigPadSettings.h"

/**
 * The key for the simulation mode.
 */
NSString * const SIMULATOR = @"Simulator";

/**
 * The key for the configuration URL.
 */
NSString * const CONFIGURATOR = @"KonfiguratorURL";

/**
 * Default configurator URL.
 */
NSString * const DEFAULT_CONFIGURATOR_URL = @"http://www.ihomelab.ch/zigpad/1/zigpad/config.xml";

@implementation ZigPadSettings

// Contains the shared instance of the class.
static ZigPadSettings * _sharedInstance = nil;

+(ZigPadSettings*) sharedInstance
{    
    @synchronized([ZigPadSettings class])
	{
        // Check if an instance already exists, if not, create one.
		if (!_sharedInstance)
			[[self alloc] init];
        
		return _sharedInstance;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([ZigPadSettings class])
	{
        // Make sure that only a single instance can be created.
		NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedInstance = [super alloc];
		return _sharedInstance;
	}
    
	return nil;
}

-(id)init
{
	self = [super init];
	if (self != nil) {
        // Get the standard userdefaults instance.
		standardUserDefaults = [NSUserDefaults standardUserDefaults];
	}
    
	return self;
}

/**
 * Returns the proper key part for IP/Port depending on the simulation mode.
 * @param simulationMode YES if the key for the simulation mode should be used.
 */
- (NSString *) modeKey: (BOOL) simulationMode {
    return simulationMode ? @"Simulation" : @"Real";
}

/**
 * Setter method for the simulationMode property.
 */
-(void)setSimulationMode:(BOOL)simulationMode
{
    [standardUserDefaults setBool:simulationMode forKey:SIMULATOR];
}

/**
 * Getter method for the simulationMode property.
 */
- (BOOL)simulationMode
{	
    return [standardUserDefaults boolForKey:SIMULATOR];
}

/**
 * Setter method for the configurationURL property.
 */
-(void)setConfiguratorURL:(NSString *)configuratorURL
{
    [standardUserDefaults setObject:configuratorURL forKey:CONFIGURATOR];
}

/**
 * Get method for the configurationURL property.
 */
- (NSString *) configuratorURL
{	
    NSString *url = [standardUserDefaults stringForKey:CONFIGURATOR];
    if (url == nil || [url isEqualToString:@""]) {
        // If the current string is empty, use the default.
        url = DEFAULT_CONFIGURATOR_URL;
    }
    return url;
}

/**
 * Getter method for the IP property.
 */
- (NSString *) ip {
    NSString *key = [NSString stringWithFormat:@"%@ServerIp", [self modeKey: self.simulationMode]];
    
    return [standardUserDefaults stringForKey:key];
}

/**
 * Getter method for the port property.
 */
- (int) port {
    NSString *key = [NSString stringWithFormat:@"%@ServerPort", [self modeKey: self.simulationMode]];
    
    return [standardUserDefaults integerForKey:key];
}

/**
 * Setter method for the ip property.
 */
-(void)setIP: (NSString *) ip simulationMode: (BOOL) simulationMode {
    NSString *key = [NSString stringWithFormat:@"%@ServerIp", [self modeKey: simulationMode]];
  
    [standardUserDefaults setObject:ip forKey:key];
}

/**
 * Setter method for the port property.
 */
-(void)setPort: (int) port simulationMode: (BOOL) simulationMode {
    NSString *key = [NSString stringWithFormat:@"%@ServerPort", [self modeKey: simulationMode]];

    [standardUserDefaults setInteger:port forKey:key];
}

/**
 * Getter method for the modeColor property.
 */
- (UIColor *) modeColor {
    //set navigation bar to red if simulation is on (to warn user)
    if (self.simulationMode) {
        // If the simulation mode is on, display a red bar.
        return [UIColor redColor];
    }
    else {
        // If not, return the default color.
        return [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
    }
}


@end
