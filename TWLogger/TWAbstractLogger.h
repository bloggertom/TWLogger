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
 Create a new instance of a TWFileLogger with a given set of options.
 
 @param options Options which will determin how the File logger will behave.
 
 @return newly initialized TWFileLogger.
 */
-(instancetype)initWithOptions:(TWLoggerOptions *)options;

-(void)stopLoggingWithMessage:(NSString *)message andError:(nullable NSError *)error;

-(void)addLogEntry:(TWLogEntry *)entry;


@end
