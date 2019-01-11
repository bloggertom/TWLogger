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
 Prefix given to the log file.
 */
@property (nonatomic)NSString *logFilePrefix;

/**
 Dictionary to hold data about the logs.
 */
@property (nonatomic, strong)NSDictionary *metaData;
@end
