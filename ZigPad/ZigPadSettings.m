//
//  ZigPadSettings.m
//  ZigPad
//
//  Created by ceesar on 19/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "ZigPadSettings.h"
#define SIMULATOR @"Simulator"
#define CONFIGURATOR @"KonfiguratorURL"


@implementation ZigPadSettings

static ZigPadSettings * _sharedInstance = nil;

+(ZigPadSettings*) sharedInstance {
    
    @synchronized([ZigPadSettings class])
	{
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
		NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedInstance = [super alloc];
		return _sharedInstance;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		standardUserDefaults = [NSUserDefaults standardUserDefaults];
	}
    
	return self;
}

-(void)setSimulationMode:(BOOL)simulationMode
{
    [standardUserDefaults setBool:simulationMode forKey:SIMULATOR];}

- (BOOL)simulationMode
{	
    return [standardUserDefaults boolForKey:SIMULATOR];
}

-(void)setConfiguratorURL:(NSString *)configuratorURL
{
    [standardUserDefaults setObject:configuratorURL forKey:CONFIGURATOR];}

- (NSString *) configuratorURL
{	
    NSString *url = [standardUserDefaults stringForKey:CONFIGURATOR];
    if (url == nil || [url isEqualToString:@""]) {
        url = @"http://z.worldempire.ch/1/zigpad/config.xml";
    }
    return url;
}

- (NSString *) modeKey: (BOOL) simulationMode {
    return simulationMode ? @"Simulation" : @"Real";
}

- (NSString *) ip {
    NSString *key = [NSString stringWithFormat:@"%@ServerIp", [self modeKey: self.simulationMode]];
    
    return [standardUserDefaults stringForKey:key];
}

- (int) port {
    NSString *key = [NSString stringWithFormat:@"%@ServerPort", [self modeKey: self.simulationMode]];
    
    return [standardUserDefaults integerForKey:key];
}

-(void)setIP: (NSString *) ip simulationMode: (BOOL) simulationMode {
    NSString *key = [NSString stringWithFormat:@"%@ServerIp", [self modeKey: simulationMode]];
    
    NSLog(@"Setting IP for %@ to %@ (%@)", [self modeKey: simulationMode], ip, key);
    
    [standardUserDefaults setObject:ip forKey:key];
}
-(void)setPort: (int) port simulationMode: (BOOL) simulationMode {
    NSString *key = [NSString stringWithFormat:@"%@ServerPort", [self modeKey: simulationMode]];
    
    NSLog(@"Setting Port for %@ to %d (%@)", [self modeKey: simulationMode], port, key);
    
    [standardUserDefaults setInteger:port forKey:key];
}

- (UIColor *) modeColor {
    //set navigation bar to red if simulation is on (to warn user)
    if (self.simulationMode) {
        return [UIColor redColor];
    }
    else {
        return [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
    }
}


@end
