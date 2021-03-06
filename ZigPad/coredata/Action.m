//
//  Action.m
//  ZigPad
//
//  Created by ceesar on 25/04/11.
//  Copyright (c) 2011 CEESAR. All rights reserved.
//

#import "Action.h"
#import "Sequence.h"


@implementation Action
@dynamic name;
@dynamic type;
@dynamic favorite;
@dynamic refId;
@dynamic sequences;
@dynamic params;

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


- (void)addParamsObject:(Param *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"params"] addObject:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeParamsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"params"] removeObject:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addParams:(NSSet *)value {    
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"params"] unionSet:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeParams:(NSSet *)value {
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"params"] minusSet:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (Param *) getParamForKey:(NSString *) key {
    for (Param *p in self.params) {
        if ([p.key isEqualToString:key]) {
            return p;
        }
    }
    return nil;
}


@end
