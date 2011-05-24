//
//  XMLParser.h
//  Browser
//
//  Created by ceesar on 3/28/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This Class is used to handle events called from Importer Class.
 *
 * The methods decide how to persist contents (attributes) from the actual XML
 * tag with CoreData.
 * 
 * It is very important that the methods are called in the correct order,
 * specifically, the addActionRef() and addSequenceRef() methods must only be
 * called after the corresponding actions and sequences have been added.
 */
@interface Config : NSObject {
    
}

/**
 * Analyzes an action tag and puts attributes into the core database.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addAction:(NSDictionary*)attrib;

/**
 * Analyzes a param tag and puts attributes into the core database.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addParam:(NSDictionary*)attrib;

/**
 * Analyzes a sequence tag and puts attributes into the core database.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addSequence:(NSDictionary*)attrib;

/**
 * Creates a reference to an already existing action for the last added sequence.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addActionRef:(NSDictionary*)attrib;

/**
 * Analyzes a presentation tag and puts attributes into the core database.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addPresentation:(NSDictionary*)attrib;

/**
 * Creates a reference to an already existing sequence for the last added presentation.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addSequenceRef:(NSDictionary*)attrib;

/**
 * Analyzes a server tag and stores the settings.
 *
 * The settings are stored through the ZigPadSettings class.
 *
 * @param attrib A dictionary with all attributes of the xml tag.
 */
-(void)addServer:(NSDictionary*)attrib;

/**
 * Persist the added information into the database.
 */
-(void)saveToDB;

/**
 * Clear the database.
 *
 * This must be called before updating the database to avoid duplicates.
 */
-(void)clearDB;

/**
 * Prints the current database information into the log.
 */
-(void)printDB;

/**
 * Abort the current import and return to the previous state.
 */
-(void)rollback;

@end







