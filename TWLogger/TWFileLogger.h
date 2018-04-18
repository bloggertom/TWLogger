//
//  TDWFileLogger.h
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLog.h"
#import "TWLogDelegate.h"
#import "TDWLoggerOptions.h"
@interface TWFileLogger : NSObject <TWLoggerDelegate>

-(instancetype)initWithOptions:(TDWLoggerOptions *)options;


@end
