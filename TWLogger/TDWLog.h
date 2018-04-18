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
+(id<TDWLoggerDelegate>)removeLogger:(id<TDWLoggerDelegate>)logger;
+(void)addLogger:(id<TDWLoggerDelegate>)logger;
+(void)systemLog:(NSString *)body;


void tdwLogD(const char *file, const char *functionName, NSString *format, ...);
void tdwLogL(const char *file, const char *functionName, TDWLogLevel level, NSString *format, ...);

@end
