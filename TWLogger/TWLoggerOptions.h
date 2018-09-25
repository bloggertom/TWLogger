//
//  TWLoggerOptions.h
//  TWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLogFormatter.h"

/**
 @class TWLoggerOptions
 
 @discussion class for holding options which configures how a logger is going to behave. How properties are interpreted will depend on the type of logger used.
 */
@interface TWLoggerOptions : NSObject

/**
 Addess to where the logs will be stored. File or URL depending on logger type.
 */
@property (nonatomic, strong)NSString *loggingAddress;

/**
 Span of time which a log page will be used before starting a new page. If nil a page will never expire.
 */
@property (nonatomic, strong)NSDateComponents *pageLife;

/**
 @brief Maximum size of a page
 
 @note How size is interpreted will depend of the type of logger.
 */
@property (nonatomic)NSUInteger maxPageSize;

/**
 @brief Maximum number of pages.
 
 The maximum number of pages allowed by logger.
 
 @note Once maximum pages have been reached the logger will decide how to continue.
 */
@property (nonatomic)NSUInteger maxPageNum;

/**
 Prefix given to the log file.
 */
@property (nonatomic)NSString *logFilePrefix;

/**
 Format defining how the log will be formatted when it is written.

 If nil no additonal infomration is added to logged text.
 */
@property (nonatomic, strong)TWLogFormatter *logFormat;

/**
 Sets how often the log cache is flushed to disk. If nil the periodic flush will not run.
 
 @note Must be used coordination with cacheSize to set the behaviour of logging cache. If flushPeriod is nil and cacheSize is 0 logs will be written to disk immediately.
 */
@property (nonatomic, strong)NSDateComponents *flushPeriod;

/**
 Sets the number of logs which are cached before being written to disk.
 If 0 logs will be written to disk at the end at the end of the next flush period. If the flushPeriod property is nil then logs will be written to disk immediately.
 
 @note Must be used coordination with flushPeriod to set the behaviour of loggin cache.
 */
@property (nonatomic)NSUInteger cacheSize;

/**
 Dictionary to hold data about the logs.
 */
@property (nonatomic, strong)NSDictionary *metaData;
@end
