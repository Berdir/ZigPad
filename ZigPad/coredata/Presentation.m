//
//  Presentation.m
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Presentation.h"
#import "Sequence.h"


@implementation Presentation
@dynamic name;
@dynamic comment;
@dynamic sequencesOrdering;
@dynamic refId;
@dynamic sequences;

@synthesize activeSequence = _activeSeq;;
@synthesize activeAction = _activeAct;
@synthesize indexMapping = _indexMapping; //Mapps all indexes of Sequences and Actions to an Array
                                          // to Format: Array Length = length of Sequence-Array
                                          // and Array Contents = length of Action arrays

int activeSequencesIndex = 0;
int activeActionsIndex = 0;
bool isFirstCallOfGetNextMethod = true;



- (void)addSequencesObject:(Sequence *)value {    
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sequences"] addObject:value];
    [self didChangeValueForKey:@"sequences" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSequencesObject:(Sequence *)value {
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

- (NSArray *) orderedSequences {	
    return [self orderedValueForKey:@"sequences"];
}


- (void) doIndexMapping
{
    //if not already done..
    if (self.indexMapping == nil || [self.indexMapping count] == 0) 
    {
        //see decription on the top of class
        NSMutableArray* a = [[NSMutableArray alloc ]init];
    
        NSArray* _sequences = self.orderedSequences;
    
        for (int i = 0; i<[_sequences count]; i++) {
            Sequence* _seq = [_sequences objectAtIndex:i];
            NSNumber* j = [NSNumber numberWithInt:[_seq.actions count]];
            [a addObject:j];
        }

        self.indexMapping = a;
        [a release];
    }
}

-(void) toggleIndexes:(int) i
{
        
        //increment or decrement
        int actionsCounts = [[self.indexMapping objectAtIndex:activeSequencesIndex]intValue];
        activeActionsIndex += i;
    
        //if all actions done within active sequence go next/previous sequence
        if (activeActionsIndex >= actionsCounts || activeActionsIndex <0) {
            activeSequencesIndex +=i;
            activeActionsIndex = 0; //set action per default to first of sequence
            if (i < 0 && activeSequencesIndex >= 0) // if wanna go previous set action to last of sequence
            {
                actionsCounts = [[self.indexMapping objectAtIndex:activeSequencesIndex]intValue];
                activeActionsIndex = actionsCounts -1;
            }
        }
    
}

//called by ActionViewController to determine if a sequence initial Command must be sent
- (bool) actionIsFirstInSequence
{
    return (activeActionsIndex == 0)?true:false;
}

-  (Action*) getNextAction
{
    
    [self doIndexMapping];
    
    //increment action (the first time do nothing)
    if (!isFirstCallOfGetNextMethod) [self toggleIndexes:+1];

    
    //if end reached 
    if (activeSequencesIndex >= [self.indexMapping count])
    {
        activeActionsIndex = 0; 
        activeSequencesIndex = 0;
        isFirstCallOfGetNextMethod = true;
        return nil;
    }
    
    NSArray* _sequences = self.orderedSequences;
    Sequence* _seq = [_sequences objectAtIndex:activeSequencesIndex];
    NSArray* _actions = _seq.orderedActions;
    
    self.activeSequence = _seq;
    Action* _act = [_actions objectAtIndex:activeActionsIndex];
    self.activeAction = _act;

    //prepare for next methode call
    if (isFirstCallOfGetNextMethod) isFirstCallOfGetNextMethod = false;


    return self.activeAction;
    
}


- (Action*) getPreviousAction
{  
    [self doIndexMapping];
    [self toggleIndexes: -1];
    
    //if end reached 
    if (activeSequencesIndex < 0)
    {
        activeActionsIndex = 0; 
        activeSequencesIndex = 0;
        isFirstCallOfGetNextMethod = true;
        return nil;
    }
    
    NSArray* _sequences = self.orderedSequences;
    Sequence* _seq = [_sequences objectAtIndex:activeSequencesIndex];
    NSArray* _actions = _seq.orderedActions;
    
    self.activeSequence = _seq;
    Action* _act = [_actions objectAtIndex:activeActionsIndex];
    self.activeAction = _act;
    
    
    return self.activeAction;
    
}

- (Action*) jumpToSequence: (int) index {

    activeSequencesIndex = index;
    
    NSArray* _sequences = self.orderedSequences;
    Sequence* _seq = [_sequences objectAtIndex:activeSequencesIndex];
    NSArray* _actions = _seq.orderedActions;
    
    activeActionsIndex = 0;
    Action* _act = [_actions objectAtIndex:activeActionsIndex];
    
    self.activeAction = _act;
    self.activeSequence = _seq;

    return self.activeAction;
}


- (void) dealloc {
    activeSequencesIndex = 0; //because Memorymanager makes recycling of deallocated objects
    activeActionsIndex = 0;
    isFirstCallOfGetNextMethod = true;

    [_indexMapping release];
    [_activeAct release];
    [_activeSeq release];
    [super dealloc];
}

@end
