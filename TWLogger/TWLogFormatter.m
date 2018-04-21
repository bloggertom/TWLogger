//
//  TWLogFormatter.m
//  TWLogger
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWLogFormatterProject.h"
#import "TWLogDelegate.h"

NSString * const TWLogFormatDateTime = @"<TW.LogFormat.DateTime>";
NSString * const TWLogFormatLevel = @"<TW.LogFormat.LogLevel>";
NSString * const TWLogFormatFile = @"<TW.LogFormat.File>";
NSString * const TWLogFormatFunction = @"<TW.LogFormat.Function>";
NSString * const TWLogFormatBody = @"<TW.LogFormat.Body>";

@implementation TWLogFormatter

-(instancetype)initWithFormat:(NSString *)format{
	self = [super init];
	if(self){
		_format = format;
	}
	return self;
	
}

-(NSString *)formatLog:(TDWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method{
	
	NSString *logString = body;
	if(self.format != nil){
		NSString *tempBody = self.format.copy;
		
		if([tempBody rangeOfString:TWLogFormatDateTime].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatDateTime withString:[NSString stringWithFormat:@"%@", [NSDate date]]];
		}
		
		if([tempBody rangeOfString:TWLogFormatBody].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatBody withString:body];
		}
		
		if([tempBody rangeOfString:TWLogFormatFile].location){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatFile withString:file];
		}
		
		if([tempBody rangeOfString:TWLogFormatFunction].location){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatFunction withString:method];
		}
		
		logString = tempBody;
	}
	
	return logString;
}

@end
