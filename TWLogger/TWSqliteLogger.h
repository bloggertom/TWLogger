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
 
 - logFormat is ignored, values are stored in there own columns in the database.
 
 @note
 By default the database will be put in the Documents directory in a @code TWLogFiles @endcode subdirectory.
 

 Metadata is persisted at the point of initialization in a separate metadata table in the sqlite database. Old metadata is replace by the new metadata if metadata is found in the database at the point of the next intialization. Passing nil for the metaData option will not remove the old metadata.
 */

@interface TWSqliteLogger : TWAbstractLogger

/**
 Defines how old a log entry can be before it is cleared from the database. If nil log entries will be stored indefinitely.
 */
@property (nonatomic, strong)NSDateComponents *logExpiration;

@end
