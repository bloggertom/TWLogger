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
 Dictionary to hold data about the logs.
 */
@property (nonatomic, strong)NSDictionary *metaData;
@end
