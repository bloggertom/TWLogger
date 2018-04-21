//
//  TDWFileLogger.h
//  TWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLog.h"
#import "TWLogDelegate.h"
#import "TWLoggerOptions.h"
@interface TWFileLogger : NSObject <TWLoggerDelegate>

/**
 Create a new instance of a TWFileLogger with a given set of options.
 
 @param options Options which will determin how the File logger will behave.
 
 @return newly initialized TWFileLogger.
 */
-(instancetype)initWithOptions:(TWLoggerOptions *)options;


@end
