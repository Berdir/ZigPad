//
//  Database.h
//  ZigPad
//
//  Created by ceesar on 06/04/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Database : NSObject {
    
}

+(Database*) sharedInstance;


- (NSURL *)applicationDocumentsDirectory;
- (id) createEntity: (NSString *) name;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
