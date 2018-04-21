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

@protocol TWLoggerDelegate <NSObject>
/**
 Boolean indicating if logger is currently active and logging.
 */
@property (nonatomic, getter=isLogging)BOOL logging;

/**
 Callback called when a log is recieved.
 
 @param level Log level of the log received @see TWLogLevel.
 @param body Main body of the log text.
 @param file File which issued the log.
 @param function Function within the file which issued the log.
 */
-(void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function;
/**
 Request the logger to stop logging. Called just before the logger is removed from active logger list
 */
-(void)stopLogging;
@end
#endif /* LogDelegate_h */
