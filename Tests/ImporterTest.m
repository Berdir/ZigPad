// For iOS
#import <GHUnitIOS/GHUnit.h>
#import "Importer.h"


@interface ImporterTest : GHTestCase { }
@end

@implementation ImporterTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)testExampleImport {
    
    Importer* parser = [[Importer alloc]init];
    
    [parser parseXMLFile:@"xml-example.xml"];
    [parser release];
    parser = nil;
    
    /*NSString *a = @"bar";
    GHTestLog(@"I can log to the GHUnit test console: %@", a);
    
    // Assert a is not NULL, with no custom error description
    GHAssertNotNULL(a, nil);
    
    // Assert equal objects, add custom error description
    NSString *b = @"bar";
    GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);*/
}

@end