//
//  LocalPicture.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OrderingPlugin.h"

@class Param, Sequence;

@interface LocalPicture : OrderingPlugin {

}
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) Sequence * sequence;
@property (nonatomic, retain) Param * param;

@end
