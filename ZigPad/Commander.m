//
//  Commander.m
//  ZigPad
//
//  Created by ceesar on 07/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "Commander.h"

/**
 * Indicate which class should be used as the actual implementation.
 *
 * When changing this, remember to also update the @class statement below.
 */
NSString * const COMMANDER_IMPL = @"TCPCommander";

@implementation Commander

// Stores the singleton instance of the defaultCommander.
static Commander * _defaultCommander = nil;

+(Commander*) defaultCommander {
    
    // Synchronized to make sure that only a single instance is created.
    @synchronized([Commander class])
	{
        // Check if a default commander exists, if not, create one.
		if (!_defaultCommander)
			_defaultCommander = [[NSClassFromString(COMMANDER_IMPL) alloc] init];
        
		return _defaultCommander;
	}
    
	return nil;
}

+(void) close {
    [_defaultCommander release];
    _defaultCommander = nil;
}

+(id)alloc
{
	@synchronized([Commander class])
	{
        // Another check to make sure that only a single instance is created.
		NSAssert(_defaultCommander == nil, @"Attempted to allocate a second instance of a singleton.");
		_defaultCommander = [super alloc];
		return _defaultCommander;
	}
    
	return nil;
}

-(void) sendString: (NSString*) message {
    // This is an abstract method, throw an exception if called directly.
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];    
}

-(void) sendAction:(Action *)msg
{
    Param *p = [msg getParamForKey:@"command"];
    if (p != nil) {
       [self sendString: p.value];
        NSLog(@"Sending action command %@" ,p.value);
    }
}

@end
