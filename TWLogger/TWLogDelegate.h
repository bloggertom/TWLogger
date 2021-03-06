//
//  LogDelegate.h
//  TWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef LogDelegate_h
#define LogDelegate_h
#import	<Foundation/Foundation.h>
#import "TWLogLevel.h"
#import "TWLoggerOptions.h"

@protocol TWLoggerDelegate <NSObject>
/**
 Boolean indicating if logger is currently active and logging. To be set at the end of startLogging and at the start of endLogging.
 */
@property (nonatomic, getter=isLogging)BOOL logging;

/**
 The logger options for this logger.
 */
@property (nonatomic, readonly, strong)TWLoggerOptions* options;

/**
 @brief Set up function for the logger.
 
 Called before the logger is added to the active logger list. Use this method to set up logging resourses and establish connections.
 
 @return boolean indicating if log was opened successfully.
 */
-(BOOL)startLogging;

/**
 Callback called when a log is recieved.
 
 @param level Log level of the log received @see TWLogLevel.
 @param body Main body of the log text.
 @param file File which issued the log.
 @param function Function within the file which issued the log.
 */
-(void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function;
/**
 @brief Tear down function for logger.
 
Called just before the logger is removed from active logger list. Use this method to clean up any resourses being used and close any connections.
 */
-(void)stopLogging;

@end
#endif /* LogDelegate_h */
