//
//  TDWLogger.h
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NSLog(args...) twLogD(__FILE__,__PRETTY_FUNCTION__,args);
#define TWLog(TWLogLevel, args...) twLogL(__FILE__,__PRETTY_FUNCTION__, TWLogLevel, args);
//! Project version number for TDWLogger.
FOUNDATION_EXPORT double TWLoggerVersionNumber;

//! Project version string for TDWLogger.
FOUNDATION_EXPORT const unsigned char TWLoggerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TDWLogger/PublicHeader.h>
#import <TWLogger/TWLog.h>
#import	<TWLogger/TWFileLogger.h>
#import	<TWLogger/TWLoggerOptions.h>
#import <TWLogger/TWLogLevel.h>
#import <TWLogger/TWLogFormatter.h>

