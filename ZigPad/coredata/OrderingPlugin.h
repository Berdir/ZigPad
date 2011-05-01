//
//  OrderingPlugin.h
//  ZigPad
//
//  Created by Markus Zimmermann on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// inherit hierarchy should be
//
// NSManagedObject
//      |
// OrderingPlugin
//      |
// MyCoreDataEntity

#import <Foundation/Foundation.h>


@interface OrderingPlugin : NSManagedObject {
    
}
@property (nonatomic, retain) NSString * orderingKey;//temporraryOrderNr value depends on this key
@property (nonatomic, retain) NSNumber * autoIncrement; //increments after value is stored to NSSet
@property (nonatomic, retain) NSNumber * temporaryOrderNr; //will be sorted by this key later

@property (nonatomic, retain) NSString* sortKeyValuesfromWrapperClass; //Values are int, Keys are NSCFString

//to get the set ordered
//calling example: NSArray* a = [myCoreDataEntity getOrderdSet:myCoreDataEntity.myNSSetContents]
-(NSArray*)getOrderdSet:(NSSet*)theSet;

//call that method after calling generated code in subclass (i.e. addMyPropertiesObject:(MyProperty *)value)
//the storeing order is FIFO (at runtime), the orderingKey ma be an ID of EntityClass that wraps a NSset
-(void)registerObjectToOrder:(NSString*)orderingKey: (OrderingPlugin*) aValue;



@end
