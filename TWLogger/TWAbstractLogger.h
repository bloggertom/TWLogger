//
//  AbstractLogger.h
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLogDelegate.h"
#import	"TWLoggerOptions.h"
#import "TWLogEntry.h"
#import "TWLoggerErrors.h"

@interface TWAbstractLogger : NSObject <TWLoggerDelegate>

@property (nonatomic, readonly, strong)TWLoggerOptions *options;
@property (nonatomic, readonly, strong)NSFileManager *fileManager;
@property (strong, readonly)NSMutableArray *logStore;

/**
 Boolean indicating if logger is currently active and logging.
 
 The value of this property is used to set and trigger log flushing.
 */
@property (nonatomic, getter=isLogging)BOOL logging;

/**
 Create a new instance of a TWLogger with a given set of options.
 
 @param options Options which will determin how the logger will behave.
 
 @return newly initialized TWLogger.
 */
-(instancetype)initWithOptions:(TWLoggerOptions *)options;

/**
 Helper method to log out to the system log with an error. A call to stop logging with proceed a call to this method.
 
 @param message Message to be logged out in the system log.
 @param error Error which will proceed the message.
 */
-(void)stopLoggingWithMessage:(NSString *)message andError:(nullable NSError *)error;

/**
 Adds a log to the logging cache.
 
 @param entry TWLogEntry object to be placed in the cache.
 */
-(void)addLogEntry:(TWLogEntry *)entry;

/**
 Abstract method called by the TWAbstractLogger super class and to be overriden by the subclass. Implementation of this methods should write any logs currently in the logStore to disk.
 
 Once called by the TWAbstractLogger super class the logStore will be emptied.
 
 Calling this method directly can lead to duplicate logging.
 */
-(void)flushLogs;
@end
