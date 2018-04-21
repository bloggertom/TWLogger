//
//  TWLoggerOptions.h
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWLoggerOptions : NSObject

/**
 Path to the directory where logs will be stored.
 */
@property (nonatomic, strong)NSString *loggingDirectory;

/**
 Span of time which a log page will be used before starting a new page.
 */
@property (nonatomic, strong)NSDateComponents *pageLife;
/**
 @brief Maximum size of a page
 
 How size is determined will depend of the type of logger being used.
 */
@property (nonatomic)NSUInteger maxPageSize;
/**
 @brief Maximum number of pages.
 
 The maximum number of pages allowed by logger.
 */
@property (nonatomic)NSUInteger maxPageNum;

/**
 Prefix given to the log file.
 */
@property (nonatomic)NSString *logFilePrefix;

/**
 Format defining how the log will be formatted when it is written.
 
 Defaults to:
 @code
 	TWLogFormatLevel:TWLogFormatDateTime [TWLogFormatFile:TWLogFormatFunction]  TWLogFormatBody
 @endcode
 */
@property (nonatomic, strong)NSString *logFormat;
/**
 Date time format to be used when writing date time to log. Defaults to YYYYMMdd:HHmmss.
 */
@property (nonatomic, strong)NSString *dateTimeFormat;

@end
