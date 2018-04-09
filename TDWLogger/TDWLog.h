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

//Setters/Getters
+(void)setDelegate:(id<TDWLoggerDelegate>)delegate;
+(void)setDefaultLogLevel:(TDWLogLevel)level;
+(BOOL)isLogging;
+(void)log:(BOOL)logging;
void tdwLog(const char *file, const char *functionName, NSString *format, ...);

@end
