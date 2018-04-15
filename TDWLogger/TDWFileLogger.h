//
//  TDWFileLogger.h
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDWLogDelegate.h"
#import "TDWLoggerOptions.h"
@interface TDWFileLogger : NSObject <TDWLoggerDelegate>

-(instancetype)initWithOptions:(TDWLoggerOptions *)options;


@end
