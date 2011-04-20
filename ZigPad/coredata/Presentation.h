//
//  Presentation.h
//  ERD
//
//  Created by ceesar on 22/03/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Action.h"
#import "Sequence.h"


@interface Presentation : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSSet* sequences;

@property (nonatomic, retain) Sequence *activeSequence;
@property (nonatomic, retain) Action *activeAction;

- (void)addSequencesObject:(NSManagedObject *)value;
- (Action*) getNextAction;


@end
