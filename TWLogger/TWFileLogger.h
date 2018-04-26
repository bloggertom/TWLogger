//
//  TDWFileLogger.h
//  TWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLog.h"
#import "TWAbstractLogger.h"
#import "TWLoggerOptions.h"

/**
 @class TWFileLogger
 
 The TWFileLogger write logs to a file at a specified location.
 
 Options passed in set the behaviour for this class.
 
- loggingAddress sets the location in the file system that logging files will be created.
 
 - pageLife set the length time a log file is used before a new log file is created.
 
 - maxPageSize sets the maximum size in KiloBytes a log file can be before a new one is created.
 
 - maxPageNum sets the maximum number of pages which can be created in LoggingAddress. Once maxPageNum is met the oldest log file is deleted.
 
 Default options are as follows
 @code
 options.pageLife.day = 1;
 options.dateTimeFormat = TWDateTimeFormatDefault;
 options.maxPageNum = 80;
 options.maxPageSize = 0;
 options.logFilePrefix = @"TWLog";
 @endcode
 
 By default logs will be put in the Documents directory in a @code TWLogFiles @endcode subdirectory.
 
 */

@interface TWFileLogger : TWAbstractLogger <TWLoggerDelegate>


@end
