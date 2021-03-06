//
//  Logger.h
//  TWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TWLogDelegate.h"

@interface TWLog : NSObject

/**
 Set default logging level for NSLog().
 
 @note
 Defaults to TWLogLevelDebug.
 
 @param level Level of default logging.
 */
+(void)setDefaultLogLevel:(TWLogLevel)level;
/**
 Set the logging level at which logs with a level below will be filtered out.
 
 @note
 Defaults to TWLogLevelDebug (no filter).
 
 @param level Level to set filter.
 */
+(void)setLogLevelFilter:(TWLogLevel)level;
/**
 Indicates if logging is currently active.
 
 @return YES if logging is currently active. Otherwise NO.
 */
+(BOOL)isLogging;
/**
 Set whether logging is active or not.
 
 @param logging Setting a value of NO stops all logging.
 */
+(void)log:(BOOL)logging;
/**
 Remove logger from active loggers
 @param logger Logger to be removed.
 */
+(id<TWLoggerDelegate>)removeLogger:(id<TWLoggerDelegate>)logger;
/**
 Add a logger to list of active loggers.
 
 @param logger Logger to be added to list of active loggers.
 */
+(void)addLogger:(id<TWLoggerDelegate>)logger;

/**
 Log to system bypassing active loggers.
 */
+(void)systemLog:(NSString *)body,...;


void twLogD(const char *file, const char *functionName, NSString *format, ...);
void twLogL(const char *file, const char *functionName, TWLogLevel level, NSString *format, ...);

@end
