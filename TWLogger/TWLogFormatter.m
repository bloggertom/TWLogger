//
//  TWLogFormatter.m
//  TWLogger
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWLogFormatterProject.h"
#import "TWUtils.h"
NSString * const TWDateTimeFormatDefault = @"YYYYMMdd:HHmmss";

NSString * const TWLogFormatDateTime = @"<TW.LogFormat.DateTime>";
NSString * const TWLogFormatLevel = @"<TW.LogFormat.LogLevel>";
NSString * const TWLogFormatFile = @"<TW.LogFormat.File>";
NSString * const TWLogFormatFunction = @"<TW.LogFormat.Function>";
NSString * const TWLogFormatBody = @"<TW.LogFormat.Body>";

@interface TWLogFormatter()

@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@end

@implementation TWLogFormatter

-(instancetype)init{
	return [self initWithLogFormat:[TWLogFormatter defaultLogFormat] dateTimeFormat:TWDateTimeFormatDefault];
}

-(instancetype)initWithLogFormat:(NSString *)format{
	if(format != nil){
		return [self initWithLogFormat:format dateTimeFormat:TWDateTimeFormatDefault];
	}else{
		return [self init];
	}
	
	
}
-(instancetype)initWithLogFormat:(NSString *)format dateTimeFormat:(NSString *)dateTimeFormat{
	self = [super init];
	if(self){
		if(format == nil){
			_format = [TWLogFormatter defaultLogFormat];
		}else{
			_format = format;
		}
		
		if(dateTimeFormat == nil){
			_dateTimeFormat = TWDateTimeFormatDefault;
		}else{
			_dateTimeFormat = dateTimeFormat;
		}
		_dateFormatter = [[NSDateFormatter alloc]init];
		_dateFormatter.dateFormat = _dateTimeFormat;
	}
	
	return self;
}

+(NSString *)defaultLogFormat{
	return [NSString stringWithFormat:@"%@:%@ [%@:%@] %@",TWLogFormatLevel, TWLogFormatDateTime, TWLogFormatFile, TWLogFormatFunction, TWLogFormatBody];
}

-(NSString *)formatLog:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method{
	
	NSString *logString = body;
	if(self.format != nil){
		NSString *tempBody = self.format.copy;
		
		if([tempBody rangeOfString:TWLogFormatDateTime].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatDateTime withString:[NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:[NSDate date]]]];
		}
		
		if([tempBody rangeOfString:TWLogFormatBody].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatBody withString:body];
		}
		
		if([tempBody rangeOfString:TWLogFormatFile].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatFile withString:file];
		}
		
		if([tempBody rangeOfString:TWLogFormatFunction].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatFunction withString:method];
		}
		
		if([tempBody rangeOfString:TWLogFormatLevel].location != NSNotFound){
			tempBody = [tempBody stringByReplacingOccurrencesOfString:TWLogFormatLevel withString:[TWUtils logLevelString:level]];
		}
		
		logString = tempBody;
	}
	
	return logString;
}

@end
