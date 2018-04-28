//
//  TWLoggerErrors.h
//  TWLogger
//
//  Created by Thomas Wilson on 28/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef TWLoggerErrors_h
#define TWLoggerErrors_h
#define ERROR_DOMAIN @"TWLogger"


typedef NS_ENUM(NSUInteger, TWFileLoggerError) {
	TWLoggerErrorUnknown = 2000,
	TWLoggerErrorInvalidFilePath = 2001,
	TWLoggerErrorFailedToCreateLogFile = 2002,
	TWLoggerErrorFailedToOpenLog = 2003,
	
	//sqlite errors
	TWLoggerErrorSqliteFailedToWrite = 3001,
};

#endif /* TWLoggerErrors_h */
