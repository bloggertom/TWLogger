//
//  TWLogLevel.h
//  TWLogger
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef TWLogLevel_h
#define TWLogLevel_h

/**
 @enum TWLogLevel
 @abstract Different levels of logging.
 @constant TWLogLevelDebug Logging relavant to debugging.
 @constant TWLogLevelInfo Logging with information about the general running of the application.
 @constant TWLogLevelWarning Logging indicating a warning.
 @constant TWLogLevelFatal Logging of fatal error or exception.
*/
typedef NS_ENUM(NSUInteger, TWLogLevel) {
	TWLogLevelDebug,
	TWLogLevelInfo,
	TWLogLevelWarning,
	TWLogLevelFatal
};

#endif /* TWLogLevel_h */
