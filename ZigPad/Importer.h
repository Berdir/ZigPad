//
//  Importer.h
//  Browser
//
//  Created by ceesar on 3/31/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Importer : NSObject <NSXMLParserDelegate>{
    
}

-(bool)parseXMLFile:(NSString*) fileName;

@end
