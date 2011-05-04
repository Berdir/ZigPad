//
//  XMLParser.m
//
//  Created by Markus Zimmermann 3/28/11. 
// This Class is used to handle events called from Importer Class. The methods decides how to persist
// contents (Attributes) from the actual XML Tag into coreFramework. The order of calling the methods
// is VERY VERY VERY important for correct xml-parsing
//

#import "Config.h"
#import "Action.h"
#import "Param.h"
#import "LocalPicture.h"
#import "Sequence.h"
#import "Presentation.h"
#import "Database.h"
#import "ZigPadSettings.h"
#import "ImageDownloader.h"

#import <CoreData/CoreData.h>


@implementation Config

NSString* keyCache = @"000"; //the xml-ID of the actual parent-Tag at runtime when parser iterates top-down the xml-file. 
NSMutableDictionary* managedObjectIDs; //maps all xml-ID's to ID's of Coredata-Entities

NSManagedObjectContext* context;


-(id)init
{
    id i = [super init];
    managedObjectIDs = [[NSMutableDictionary alloc]init]; 
    context =  [[Database sharedInstance] managedObjectContext];
    return i;
}

-(void)dealloc{
    [managedObjectIDs release];
    [super dealloc];
}

- (NSNumber *) getRefId: (NSDictionary *) attrib {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *refId = [f numberFromString:[attrib objectForKey:@"id"]];
    [f release];
    return refId;
}


//loads a picture from local or internet and put it into core database
-(LocalPicture * )loadPicture:(NSString*)url
{
    //NSString* url = @"http://www.die-seite.ch/movie.gif";
    //NSString* url = @"testpic.jpg";
    NSURL* picURL;
    NSData *data; //the picture binariers
    
    if ([url hasPrefix:@"http"]) //load from I-Net
    {
        /* bitte drin lassen
        picURL = [NSURL URLWithString:url]; 
        NSMutableURLRequest  *theRequest=[NSMutableURLRequest 
                                          requestWithURL:picURL
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
        NSError* error = nil;
        NSHTTPURLResponse* response = nil;
        data = [NSURLConnection sendSynchronousRequest:theRequest
                                           returningResponse:&response error:&error];
        if (([response statusCode]!=200)||([data length]==0) ) {
            NSLog(@"Picture %@ not downloaded, status code %d, data length %d, error %@",url, [response statusCode], [data length], [error localizedDescription]);
            return nil;
        }
        else {
            NSLog(@"Picture %@ downloaded successful.", url);
        }
         */
        
        data = [ImageDownloader downloadImage:url];

        
        
    } else  //then load from local file
    {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* rootdir = [bundle resourcePath];
        NSString* fileName = [NSString stringWithFormat:@"%@/%@",rootdir,url];
        data = [[NSFileManager defaultManager] contentsAtPath:fileName];
        if ([data length]==0 ) {
            NSLog(@"Picture %@ not found",url);
            return nil;
        }
        
    }
    
    //create a Coredata Object and fill with data
    LocalPicture*  lp = [[Database sharedInstance] createEntity: @"LocalPicture"]; 
    lp.picture = data;
    
    return lp;

}

//flush all entities from coredata framework
-(void)clearDB
{
    NSArray* tableList =[[NSArray alloc]initWithObjects:@"Action",@"LocalPicture",@"Param",@"Presentation",@"Sequence", nil];
    
    for (NSString* table in tableList) {
        NSFetchRequest * fetch;
        @try {
            fetch = [[NSFetchRequest alloc] init];
            [fetch setEntity:[NSEntityDescription entityForName:table inManagedObjectContext:context]];
            NSArray * result = [context executeFetchRequest:fetch error:nil];
            for (id basket in result)
                [context deleteObject:basket];
        } @catch (NSException* ex){NSLog(@"Tabelle %@ nicht vorhanden",table);}
        @finally {
            [fetch release];
        }
    }
    
    [tableList release];
}

//analyzes action tag and put attributes into the core database
-(void)addAction:(NSDictionary*) attrib
{
    // Get an action entity with a permament object id which can be used for reference
    // in BWOrderedObject.
    Action*  a = [[Database sharedInstance] createEntity:@"Action"];

    keyCache = [attrib objectForKey:@"id"]; //this information will be used by next child tag-method
    [managedObjectIDs setValue:[a objectID] forKey:keyCache];// dito
    
    a.refId = [self getRefId:attrib];
    
    a.name = [attrib objectForKey:@"name"];
    a.type = [attrib objectForKey:@"type"];    
    a.favorite = [NSNumber numberWithInt:[(NSString*)[attrib objectForKey:@"favorite"]intValue]];
    

}

//analyzes param tag and put attributes into the core database
-(void)addParam:(NSDictionary*)attrib
{
    Action* a = (Action*)[context objectWithID:[managedObjectIDs valueForKey:keyCache]];//get parent-tag
    
    Param* p = [[Database sharedInstance] createEntity:@"Param"];    
    
    p.key = [attrib objectForKey:@"key"];
    NSString* picture = [attrib objectForKey:@"picture"];//wenn es ein attribut mit namen picture gibt
    p.value = [attrib objectForKey:@"value"];
    

    [a addParamsObject:p]; //calling of a generated code.. (fill the 1:n-collection)
    
    //Put a pic into db if needed
    if (picture !=nil) {
        
        LocalPicture*  lp = [self loadPicture:picture]; 
        p.localPicture = lp;
        if (lp==nil) @throw([NSException exceptionWithName:@"PictureLoadingException" reason:@"could not load Picture" userInfo:nil]);

    }
    
}


//analyzes sequence tag and put attributes into the core database
-(void) addSequence:(NSDictionary *)attrib
{

    Sequence*  s = [[Database sharedInstance] createEntity:@"Sequence"];
    
    keyCache = [attrib objectForKey:@"id"]; //this information will be used by next child tag-method
    [managedObjectIDs setValue:[s objectID] forKey:keyCache];// dito
    
    s.name = [attrib objectForKey:@"name"];
    s.command =[attrib objectForKey:@"command"];
    NSString* icon = [attrib objectForKey:@"icon"];
    
    s.refId = [self getRefId:attrib];
    
    //put a picture into db if needed
    if (icon !=nil)
    {
        LocalPicture*  lp  = [self loadPicture:icon];
        s.icon = lp;
        if (lp==nil) @throw([NSException exceptionWithName:@"PictureLoadingException" reason:@"could not load Picture" userInfo:nil]);
    }    
}

//links an Action Reference (childtag) to the actual Sequence (parent tag)
- (void)addActionRef:(NSDictionary *)attrib
{
    Sequence* s = (Sequence*)[context objectWithID:[managedObjectIDs valueForKey:keyCache]];//get parent-tag
 
    //get an Action from dbPool
    NSString* actionRef = [attrib objectForKey:@"ref"];
    @try {
        Action* a = (Action*)[context objectWithID:[managedObjectIDs valueForKey:actionRef]];
        [s addActionsObject:a]; //calling of a generated code.. (fill the 1:n-collection)
    } @catch (NSException *exception) {
        NSLog(@"Failed to add ActionRef (ref = %@, sequence = %@)", actionRef, keyCache);
        [exception raise];
    }
    
}

//analyzes presentation tag and put attributes into the core database
-(void) addPresentation:(NSDictionary *)attrib
{

    Presentation*  s = [[Database sharedInstance] createEntity: @"Presentation"];
    
    keyCache = [attrib objectForKey:@"id"]; //this informat	ion will be used by next child tag-method
    [managedObjectIDs setValue:[s objectID] forKey:keyCache];// dito
    
    s.name = [attrib objectForKey:@"name"];
    s.comment =[attrib objectForKey:@"comment"];
    s.refId = [self getRefId:attrib];
    
}

//links an Sequence Reference (childtag) to the actual Presentation (parent tag)
-(void) addSequenceRef:(NSDictionary *)attrib
{
    Presentation* p = (Presentation*)[context objectWithID:[managedObjectIDs valueForKey:keyCache]];//get parent-tag
    
    //get an Action from dbPool
    NSString* sequenceRef = [attrib objectForKey:@"ref"];
    Sequence* s = (Sequence*)[context objectWithID:[managedObjectIDs valueForKey:sequenceRef]];
    
    [p addSequencesObject:s]; //calling of a generated code.. (fill the 1:n-collection)
    
}
//puts NSUserdefaults from the xml
-(void) addServer:(NSDictionary *)attrib
{

    NSString* type = [attrib objectForKey:@"type"];
    
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    
	if (s) {
		[s setIP:[attrib objectForKey:@"ip"] simulationMode:[type isEqualToString:@"simulator"]];
        [s setPort:[[attrib objectForKey:@"port"] intValue] simulationMode:[type isEqualToString:@"simulator"]];
	}
}

-(void) saveToDB
{
    NSError* err = nil;
    [context save:&err];
    if (err!=nil) {
        NSLog(@"DB-Save Error %@",[err localizedDescription]);
    }
    
}

//for debugging purposes
-(void)printDB
{
    
    NSLog(@"Context: %@", context);
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Presentation" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    NSError* error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];

    for (Presentation *p in result) {
        NSLog(@"Presentation %@ (id: %@) is a %@ :", p.name, p.refId, p.comment);
        for (Sequence *s in p.orderedSequences)
        {
            NSLog(@"    Sequence %@  (id: %@) with icon of size %i and command %@ has:", s.name, s.refId, [s.icon.picture length], s.command);
            for (Action* a in s.orderedActions)
            {
                NSLog(@"        Action %@  (id: %@) with type: %@  Favorite=%i with:", a.name, a.refId, a.type, [a.favorite intValue]);
                for (Param* pa in a.params)
                {
                    NSLog(@"           Param:");
                    NSLog(@"               key = %@ ", pa.key);
                    NSLog(@"               value = %@ ", pa.value);
                    NSLog(@"               Picture size = %i", [pa.localPicture.picture length]);
                    
                }
            }
        }
    }
    [request release];
}

- (void)rollback {
    [context rollback];
}




@end


