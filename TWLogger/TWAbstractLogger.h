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

typedef NS_ENUM(NSUInteger, TDWFileLoggerError) {
	TDWFileLoggerErrorUnknown = 2000,
	TDWFileLoggerErrorInvalidFilePath = 2001,
	TDWFileLoggerErrorFailedToCreateLogFile = 2002,
	TWFileLoggerErrorFailedToOpenLog = 2003
};

@interface TWAbstractLogger : NSObject <TWLoggerDelegate>

@property (nonatomic, readonly, strong)TWLoggerOptions *options;
@property (nonatomic, readonly, strong)NSFileManager *fileManager;
/**
 Create a new instance of a TWFileLogger with a given set of options.
 
 @param options Options which will determin how the File logger will behave.
 
 @return newly initialized TWFileLogger.
 */
-(instancetype)initWithOptions:(TWLoggerOptions *)options;

@end
