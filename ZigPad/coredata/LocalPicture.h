//
//  LocalPicture.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BWOrderedManagedObject.h"

@class Param, Sequence;

@interface LocalPicture : BWOrderedManagedObject {

}
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) Sequence * sequence;
@property (nonatomic, retain) Param * param;

@end
