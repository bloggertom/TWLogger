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
@property (nonatomic, readonly, strong)TWLogFormatter *logFormatter;
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

-(void)stopLoggingWithMessage:(NSString *)message andError:(nullable NSError *)error;

-(void)addLogEntry:(TWLogEntry *)entry;

/**
 Loggers inheriting from the TWAbstractLogger class should not call this method directly and instead should call setNeedsFlaush instead.
 
 Calling this method directly can lead to unpredictable behaviour.
 */
-(void)flushLogs;
@end
