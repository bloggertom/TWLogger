//
//  Logger.h
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TDWLogDelegate.h"

@interface TDWLog : NSObject

+(id<TDWLoggerDelegate>)delegate;
+(void)setDelegate:(id<TDWLoggerDelegate>)delegate;

void cLogger(const char *file, const char *functionName, NSString *format, ...);

@end
