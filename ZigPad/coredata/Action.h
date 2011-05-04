//
//  Action.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Param.h"
#import "Sequence.h"
#import "BWOrderedManagedObject.h"

@interface Action : BWOrderedManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * refId;
@property (nonatomic, retain) NSSet* sequences;
@property (nonatomic, retain) NSSet* params;

- (void)addParamsObject:(Param *)value;


@end
