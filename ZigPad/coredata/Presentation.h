//
//  Presentation.h
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Action.h"
#import "Sequence.h"
#import "OrderingPlugin.h"

@interface Presentation : OrderingPlugin {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * refId;

@property (nonatomic, retain) NSSet* sequences;



@property (nonatomic, retain) Sequence *activeSequence;
@property (nonatomic, retain) Action *activeAction;
@property (nonatomic, retain) NSMutableArray* indexMapping;

- (void)addSequencesObject:(Sequence *)value;
- (Action*) getNextAction;
- (Action*) getPreviousAction;
- (Action*) jumpToSequence: (int) index;

@end
