//
//  ZigPadSettings.m
//  ZigPad
//
//  Created by ceesar on 19/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZigPadSettings.h"
#define SIMULATOR @"Simulator"


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
    
    [standardUserDefaults setObject:ip forKey:key];
}
-(void)setPort: (int) port simulationMode: (BOOL) simulationMode {
    NSString *key = [NSString stringWithFormat:@"%@ServerPort", [self modeKey: simulationMode]];
    
    [standardUserDefaults setInteger:port forKey:key];
}


@end
