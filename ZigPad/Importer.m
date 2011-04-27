//
//  Importer.m
//
//  Created by ceesar on 3/31/11. Markus Zimmermann
// This Class parses XML-Contents from Web or a local file (xml-example.xml, testpic.jpg)
//

#import "Importer.h"
#import "Config.h"
#import <CoreData/CoreData.h>
#import "Action.h" //all generated Entity-Classes
#import "Param.h"
#import "LocalPicture.h"
#import "Sequence.h"
#import "Presentation.h"
#import "Database.h"



@implementation Importer


Config* configTag; //HelperClass to put Child-Tag Attributes to CoreDBFramework
bool importSuccess;



//the main entry of that class. 
// Parameter examples: "http://foo.bar/any" or "localfile.txt"
-(bool)parseXMLFile:(NSString*) url
{
    
    importSuccess = false;

    NSLog(@"parser started");

   
    NSURL* xmlURL;
    if (url == nil) {url = @"xml-example.xml";}

     //location of xml-file
    if ([url hasPrefix:@"http"]) //load from I-Net
    {
        xmlURL = [NSURL URLWithString:url]; 
   
    } else  //then load from local file
    {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* rootdir = [bundle resourcePath];
        NSString* fileName = [NSString stringWithFormat:@"%@/%@",rootdir,url];
        xmlURL = [NSURL fileURLWithPath:fileName];        
    }

    
    configTag = [[Config alloc]init];
    
    [configTag clearDB];
    
     NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];
    
    if (importSuccess) {	
        [configTag saveToDB];
        
        [configTag printDB];
    }
    else {
        [configTag rollback];
    }
    
    [configTag release];
    [xmlParser release];
    NSLog(@"parsing finished with %@",((importSuccess) ? @"success" : @"failure"));
    return importSuccess;
}

//a delegate Callback invoked from NSXmlParser
- (void)parser:(NSXMLParser *) parser didStartElement: (NSString *)elementName namespaceURI: (NSString *)namespaceURI
 qualifiedName: (NSString *)qName attributes: (NSDictionary *)attributeDict
{
    @try {
        if ([elementName isEqualToString:@"action"]) { [configTag addAction:attributeDict]; importSuccess = true;}
        if ([elementName isEqualToString:@"param"]) { [configTag addParam:attributeDict]; importSuccess = true;}
        if ([elementName isEqualToString:@"sequence"]) { [configTag addSequence:attributeDict]; importSuccess = true;}
        if ([elementName isEqualToString:@"actionRef"]) { [configTag addActionRef:attributeDict]; importSuccess = true;}
        if ([elementName isEqualToString:@"presentation"]) { [configTag addPresentation:attributeDict]; importSuccess=true;}
        if ([elementName isEqualToString:@"sequenceRef"]) { [configTag addSequenceRef:attributeDict]; importSuccess=true;}
        if ([elementName isEqualToString:@"server"]) { [configTag addServer:attributeDict];importSuccess=true;}
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: %@", exception);
        importSuccess = false;
        [parser abortParsing];
    }
}

@end
