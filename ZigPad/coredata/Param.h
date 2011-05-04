//
//  Param.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Action.h"
#import "LocalPicture.h"
#import "BWOrderedManagedObject.h"

@class Action;

@interface Param : BWOrderedManagedObject {
@private
}
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) Action * action;
@property (nonatomic, retain) LocalPicture * localPicture;

@end
