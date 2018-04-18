//
//  TDWUtils.m
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TDWUtils.h"

@implementation TDWUtils

+(NSString *)logLevelString:(TDWLogLevel)level{
	switch (level) {
		case TDWLogLevelInfo:
			return @"INFO";
		case TDWLogLevelWarning:
			return @"WARNING";
		case TDWLogLevelFatal:
			return @"FATAL";
		default:
			return @"DEBUG";
	}
}

@end
