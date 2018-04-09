//
//  TDWLogger.h
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NSLog(args...) cLogger(__FILE__,__PRETTY_FUNCTION__,args);
//! Project version number for TDWLogger.
FOUNDATION_EXPORT double TDWLoggerVersionNumber;

//! Project version string for TDWLogger.
FOUNDATION_EXPORT const unsigned char TDWLoggerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TDWLogger/PublicHeader.h>
#import <TDWLogger/TDWLog.h>

