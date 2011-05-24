//
//  XMLParser.m
//
//  Created by Markus Zimmermann 3/28/11. 
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

/**
 * The xml id of the actual parent-Tag at runtime when parser iterates top-down
 * through the xml file.
 */
NSString* keyCache = @"000";

/**
 * Maps all xml-ID's to ID's of Coredata-Entities.
 */
NSMutableDictionary* managedObjectIDs;

/**
 * Reference to the persistence context for CoreData.
 */
NSManagedObjectContext* context;

-(id)init
{
    id i = [super init];
    // Initalize the necessary helper variables.
    managedObjectIDs = [[NSMutableDictionary alloc]init]; 
    context =  [[Database sharedInstance] managedObjectContext];
    return i;
}

-(void)dealloc{
    [managedObjectIDs release];
    [super dealloc];
}

/**
 * Returns the xml id of a given attribute.
 *
 * @param attrib Dictionary with an id key.
 *
 * @return The id, converted to a NSNumber.
 */
- (NSNumber *) getAsNumber: (NSString *) string {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    // Get the attribute nd convert it to a number.
    NSNumber *refId = [f numberFromString:string];
    [f release];
    return refId;
}

- (NSNumber *) getRefId: (NSDictionary *) attrib {
    return [self getAsNumber:[attrib objectForKey:@"id"]];
}


/**
 * Loads a picture from local or internet and persist it.
 *
 * @param url Usually the URL to a remote image that is then downloaded, but
 *            a local path is also supported.
 *
 * @return A LocalPicture object. Nil if the remote image could not be loaded.
 */
-(LocalPicture * )loadPicture:(NSString*)url
{
    //NSString* url = @"http://www.die-seite.ch/movie.gif";
    //NSString* url = @"testpic.jpg";
    //NSURL* picURL;

    // The picture binary data.
    NSData *data;
    
    // If the url is prefixed with http, assume that it is a remote picture and
    // download it.
    if ([url hasPrefix:@"http"])
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
        // If data is nil, the download failed.
        if (data == nil) return nil;

    } else  
    {
        // Otherwise, load it as a local file.
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* rootdir = [bundle resourcePath];
        NSString* fileName = [NSString stringWithFormat:@"%@/%@",rootdir,url];
        data = [[NSFileManager defaultManager] contentsAtPath:fileName];
        if ([data length]==0 ) {
            NSLog(@"Picture %@ not found",url);
            return nil;
        }
        
    }
    
    // Create a Coredata Object and fill with data.
    LocalPicture*  lp = [[Database sharedInstance] createEntity: @"LocalPicture"]; 
    lp.picture = data;
    
    return lp;
}

-(void)clearDB
{
    // Make sure that the tables are cleared in the correct order.
    NSArray* tableList =[[NSArray alloc]initWithObjects:@"Presentation",@"Sequence",@"Action",@"Param",@"LocalPicture", nil];
    
    // Loop over all tables, fetch all entities and delete them.
    for (NSString* table in tableList) {
        NSFetchRequest * fetch;
        @try {
            fetch = [[NSFetchRequest alloc] init];
            [fetch setEntity:[NSEntityDescription entityForName:table inManagedObjectContext:context]];
            NSArray * result = [context executeFetchRequest:fetch error:nil];
            for (id basket in result)
                [context deleteObject:basket];
        } @catch (NSException* ex)
        {
            NSLog(@"Tabelle %@ nicht vorhanden", table);
        }
        @finally {
            [fetch release];
        }
    }
    
    [tableList release];
}

-(void)addAction:(NSDictionary*) attrib
{
    // Get an action entity with a permament object id which can be used for 
    // reference in BWOrderedObject.
    Action*  a = [[Database sharedInstance] createEntity:@"Action"];

    keyCache = [attrib objectForKey:@"id"]; //this information will be used by next child tag-method
    [managedObjectIDs setValue:[a objectID] forKey:keyCache];// dito
    
    a.refId = [self getRefId:attrib];
    
    a.name = [attrib objectForKey:@"name"];
    a.type = [attrib objectForKey:@"type"];    
    a.favorite = [self getAsNumber:[attrib objectForKey:@"favorite"]];
}

-(void)addParam:(NSDictionary*)attrib
{
    // Get parent action.
    Action* a = (Action*)[context objectWithID:[managedObjectIDs valueForKey:keyCache]];
    
    Param* p = [[Database sharedInstance] createEntity:@"Param"];    
    
    p.key = [attrib objectForKey:@"key"];
    NSString* picture = [attrib objectForKey:@"picture"];
    p.value = [attrib objectForKey:@"value"];
    
    // Calling of a generated code.. (fill the 1:n-collection).
    [a addParamsObject:p];
    
    // If there is a picture url, load it.
    if (picture != nil)
    {
        p.localPicture = [self loadPicture:picture];
        if (p.localPicture == nil)
        {
            @throw([NSException exceptionWithName:@"PictureLoadingException" reason:@"could not load Picture" userInfo:nil]);
        }

    }
    
}

-(void) addSequence:(NSDictionary *)attrib
{
    Sequence*  s = [[Database sharedInstance] createEntity:@"Sequence"];
    
    // This information will be used by next child tag-method.
    keyCache = [attrib objectForKey:@"id"]; 
    [managedObjectIDs setValue:[s objectID] forKey:keyCache];
    
    s.name = [attrib objectForKey:@"name"];
    s.command =[attrib objectForKey:@"command"];
    NSString* icon = [attrib objectForKey:@"icon"];
    
    s.refId = [self getRefId:attrib];
    
    // If there is an icon url, load and save it.
    if (icon != nil)
    {
        s.icon = [self loadPicture:icon];
        if (s.icon == nil) { 
            @throw([NSException exceptionWithName:@"PictureLoadingException" reason:@"could not load Picture" userInfo:nil]);
        }
    }    
}

- (void)addActionRef:(NSDictionary *)attrib
{
    // Get parent sequence.
    Sequence* s = (Sequence*)[context objectWithID:[managedObjectIDs valueForKey:keyCache]];
 
    // Get the Action.
    NSString* actionRef = [attrib objectForKey:@"ref"];
    @try {
        Action* a = (Action*)[context objectWithID:[managedObjectIDs valueForKey:actionRef]];
        // Calling of a generated code.. (fill the 1:n-collection).
        [s addActionsObject:a];
    } @catch (NSException *exception) {
        NSLog(@"Failed to add ActionRef (ref = %@, sequence = %@)", actionRef, keyCache);
        [exception raise];
    }
    
}

-(void) addPresentation:(NSDictionary *)attrib
{
    Presentation*  s = [[Database sharedInstance] createEntity: @"Presentation"];
    
    // This information will be used by next child tag-method.
    keyCache = [attrib objectForKey:@"id"];
    [managedObjectIDs setValue:[s objectID] forKey:keyCache];
    
    s.name = [attrib objectForKey:@"name"];
    s.comment =[attrib objectForKey:@"comment"];
    s.refId = [self getRefId:attrib];
}

-(void) addSequenceRef:(NSDictionary *)attrib
{
    // Get the parent presentation.
    Presentation* p = (Presentation*)[context objectWithID:[managedObjectIDs valueForKey:keyCache]];
    
    // Get the referenced sequence.
    NSString* sequenceRef = [attrib objectForKey:@"ref"];
    Sequence* s = (Sequence*)[context objectWithID:[managedObjectIDs valueForKey:sequenceRef]];
    
    // Add sequence to presentation.
    [p addSequencesObject:s];
    
}


-(void) addServer:(NSDictionary *)attrib
{
    NSString* type = [attrib objectForKey:@"type"];
    
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    
    BOOL simulationMode = [type isEqualToString:@"simulator"];
    [s setIP:[attrib objectForKey:@"ip"] simulationMode: simulationMode];
    [s setPort:[[attrib objectForKey:@"port"] intValue] simulationMode: simulationMode];
}

-(void) saveToDB
{
    NSError* err = nil;
    [context save:&err];
    if (err != nil) {
        NSLog(@"DB-Save Error %@", [err localizedDescription]);
    }
    
}

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


