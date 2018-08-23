//
//  TWSqliteLogger.h
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWAbstractLogger.h"

/**
 @class TWSqliteLogger
 
 The TWSqliteLogger class can be used to save logs to a database.
 
 Options passed in set the behaviour for this class.
 
 - pageLife defines how old a log entry can be before it is cleared from the database. If nil log entries will be stored indefinitely.
 
 - maxPageSize is ignored.
 
 - maxPageNum is ignored.
 
 - logFormat is ignored, values are stored in there own columns in the database.
 
 Default options are as follows
 @code
 options.logFilePrefix = @"TWLog";
 options.flushPeriod.seconds = 10;
 options.logFormat = nil;
 options.pageLife = nil;
 options.cacheSize = 10;
 @endcode
 
 By default the database will be put in the Documents directory in a @code TWLogFiles @endcode subdirectory.
 
 */

@interface TWSqliteLogger : TWAbstractLogger



@end
