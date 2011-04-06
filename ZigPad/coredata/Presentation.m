//
//  Presentation.m
//  ERD
//
//  Created by ceesar on 22/03/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Presentation.h"
#import "Sequence.h"

@implementation Presentation
@dynamic name;
@dynamic comment;
@dynamic sequences;

NSEnumerator *sequenceEnumerator = nil;
NSEnumerator *actionEnumerator = nil;
Sequence *activeSequence = nil;


- (void)addSequencesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sequences"] addObject:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSequencesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sequences"] removeObject:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSequences:(NSSet *)value {    
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sequences"] unionSet:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSequences:(NSSet *)value {
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sequences"] minusSet:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (Action*) getNextAction {
    // If the Sequence Enumerater is nil, we're starting from the beginning,
    // and get the first Sequence.
    if (sequenceEnumerator == nil) {
        sequenceEnumerator = [self.sequences objectEnumerator];
        activeSequence = [sequenceEnumerator nextObject];
    }
    
    // If the Action enumerator is nil, this is a new sequence.
    if (actionEnumerator == nil) {
        actionEnumerator = [activeSequence.actions objectEnumerator];
    }
    
    // Try to get next action. Repeat until either the next action object was found or no more
    // sequences exist.
    do {
        Action *a = [actionEnumerator nextObject];
    
        if (a) {
            return a;
        }
    
        // If there are no remaining actions in the active Sequence, switch sequence and try again.
        activeSequence = [sequenceEnumerator nextObject];
        if (!activeSequence) {
            sequenceEnumerator = nil;
            actionEnumerator = nil;
            return nil;
        }
        actionEnumerator = [activeSequence.actions objectEnumerator];
    } while (true);
}



@end
