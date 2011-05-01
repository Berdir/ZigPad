//
//  OrderingPlugin.m
//  ZigPad
//
//  Created by ceesar on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderingPlugin.h"


@implementation OrderingPlugin

@synthesize orderingKey = _orderingKey;
@synthesize temporaryOrderNr = _temporaryOrderNr;
@synthesize autoIncrement = _autoIncrement;
@synthesize sortKeyValuesfromWrapperClass = _sortKeysfromWrapperClass;

//helpers
-(void)increment
{
    
    int count;
    
    if (self.autoIncrement ==nil) 
        count = 0;
    else 
        count = [self.autoIncrement intValue];
    
    count++;
    
    //create a new autoincrement object for the wrapperclass
    NSNumber* tempNr = [[NSNumber alloc]initWithInt:count];
    self.autoIncrement = tempNr;
    [tempNr release];
    
}

-(void)setOrderByKey:(NSString*) orderingKey: (NSNumber*)orderID
{
    //orderinfo as Key Value Stringcode because thers no way to store a NSDIcionary attribute to coredatabase
    //Key may be a String ID of entity-class
    int value = [orderID intValue]; 
    self.sortKeyValuesfromWrapperClass = [NSString stringWithFormat:@"%@;%i\n",orderingKey,value];

}

-(NSNumber*)getOrderByKey:(NSString*)orderingKey
{
    //returns the order previous designed by key of Entity-class i.e. ID
    NSArray *lines = [self.sortKeyValuesfromWrapperClass componentsSeparatedByString:@"\n"];
    
    //iterate all KeyValue pairs
    for (int i = 0; i < [lines count]-1; i++) {
        
        NSString* line = [lines objectAtIndex:i];
        NSArray *cols = [line componentsSeparatedByString:@";"];
        
        //Compare key
        NSString* key = [cols objectAtIndex:0];
        if ([key isEqualToString:orderingKey]) {
            NSString* s = [cols objectAtIndex:1];//getValue
            int value = [s intValue];
            return [NSNumber numberWithInt:value];
        }

    }
    
    return nil;    
}
// end of helpers

-(NSArray*)getOrderdSet:(NSSet*)theSet
{
    //remark all values in the set with a order-Nr, depending of the orderingKey
    for (OrderingPlugin * item in theSet)
    {
        item.temporaryOrderNr = [item getOrderByKey:self.orderingKey];
    }
    //now sort!
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"temporaryOrderNr" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSArray* sortedSet = [theSet sortedArrayUsingDescriptors:sortDescriptors];
    
    [sortDescriptors release];
    [sortDescriptor release];

    return sortedSet;
}

-(void)registerObjectToOrder:(NSString *)orderingKey: (OrderingPlugin*) aValue
{
    [orderingKey retain];    
    [aValue retain];
    
    if (orderingKey ==nil || ![orderingKey isEqualToString:self.orderingKey])
        self.orderingKey = orderingKey; //orderinfo for the wrapperclass

    [self increment];
    [aValue setOrderByKey:orderingKey :self.autoIncrement]; //orderinfo for the Objects in the set of wrapperclass
    
    [orderingKey release];
    [aValue release];
    
}


-(void)dealloc
{
    [_autoIncrement release];
    [_temporaryOrderNr release];
    [_orderingKey release];
    [_sortKeysfromWrapperClass release];
    [super dealloc];
}


@end
