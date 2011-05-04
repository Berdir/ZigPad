//
//  ImageDownloader.m
//  ZigPad
//
//  Created by ceesar on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageDownloader.h"


@implementation ImageDownloader

+ (NSData*) downloadImage:(NSString*) url
{
    //Convert string to url
    NSURL* picURL = [NSURL URLWithString:url];
    
    //create request
    NSMutableURLRequest  *theRequest=[NSMutableURLRequest 
                                      requestWithURL:picURL
                                      cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
    
    //obtain data from internet with timeout
    NSError* error = nil;
    NSHTTPURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:theRequest
                                 returningResponse:&response error:&error];
    if (([response statusCode]!=200)||([data length]==0) ) {
        NSLog(@"Picture %@ not downloaded, status code %d, data length %d, error %@",url, [response statusCode], [data length], [error localizedDescription]);
        return nil;
    }
    else {
        NSLog(@"Picture %@ downloaded successful.", url);
    } 
    
    return data;
}

@end
