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

#define ERROR_DOMAIN @"TDWFileLogger"

typedef NS_ENUM(NSUInteger, TWFileLoggerError) {
	TWLoggerErrorUnknown = 2000,
	TWLoggerErrorInvalidFilePath = 2001,
	TWLoggerErrorFailedToCreateLogFile = 2002,
	TWLoggerErrorFailedToOpenLog = 2003
};

@interface TWAbstractLogger : NSObject <TWLoggerDelegate>

@property (nonatomic, readonly, strong)TWLoggerOptions *options;
@property (nonatomic, readonly, strong)NSFileManager *fileManager;
@property (nonatomic, readonly, strong)TWLogFormatter *logFormatter;
/**
 Create a new instance of a TWFileLogger with a given set of options.
 
 @param options Options which will determin how the File logger will behave.
 
 @return newly initialized TWFileLogger.
 */
-(instancetype)initWithOptions:(TWLoggerOptions *)options;

-(void)stopLoggingWithMessage:(NSString *)message andError:(nullable NSError *)error;

@end
