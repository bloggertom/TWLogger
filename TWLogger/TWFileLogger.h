//
//  TDWFileLogger.h
//  TWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLog.h"
#import "TWLoggerOptions.h"


/**
 @class TWFileLogger
 
 The TWFileLogger write logs to a file at a specified location.
 
 A TWFileLogger can be configured using the following properties:
 
 - pageLife set the length time a log file is used before a new log file is created.
 
 - maxPageSize sets the maximum size in KiloBytes a log file can be before a new one is created.
 
 - maxPageNum sets the maximum number of pages which can be created in LoggingAddress. Once maxPageNum is met the oldest log file is deleted.
 
 @note
 metaData key values are logged out at the top of each file.
 
 By default logs will be put in the Documents directory in a @code TWLogFiles @endcode subdirectory.
 
 */

@interface TWFileLogger : NSObject <TWLoggerDelegate>
@property (nonatomic, readonly, strong)TWLoggerOptions *options;

/**
 Format defining how the log will be formatted when it is written.
 
 If nil no additonal information is added to logged text.
 */
@property (nonatomic, strong)TWLogFormatter *logFormatter;

/**
 Span of time which a log page will be used before starting a new page. If nil a page will never expire.
 
 Default is 1 day
 */
@property (nonatomic, strong)NSDateComponents *pageLife;

/**
 @brief Maximum size of a log file in kilobytes
 
 0 by default (ignored)
 */
@property (nonatomic)NSUInteger maxPageSize;

/**
 @brief Maximum number of pages.
 
 The maximum number of log files before the oldest is deleted.
 */
@property (nonatomic)NSUInteger maxPageNum;

@end
