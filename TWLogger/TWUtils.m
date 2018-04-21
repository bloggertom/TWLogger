//
//  TDWUtils.m
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWUtils.h"

@implementation TWUtils

+(NSString *)logLevelString:(TWLogLevel)level{
	switch (level) {
		case TWLogLevelInfo:
			return @"INFO";
		case TWLogLevelWarning:
			return @"WARNING";
		case TWLogLevelFatal:
			return @"FATAL";
		default:
			return @"DEBUG";
	}
}

@end
