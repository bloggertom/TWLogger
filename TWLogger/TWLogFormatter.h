//
//  TWLogFormatter.h
//  TWLogger
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLogLevel.h"
extern NSString * const TWDateTimeFormatDefault;

extern NSString * const TWLogFormatDateTime;
extern NSString * const TWLogFormatLevel;
extern NSString * const TWLogFormatFile;
extern NSString * const TWLogFormatFunction;
extern NSString * const TWLogFormatBody;

@interface TWLogFormatter : NSObject

@property (nonatomic, strong)NSString *format;
@property (nonatomic, strong)NSString *dateTimeFormat;

-(instancetype)initWithLogFormat:(NSString *)format;
-(instancetype)initWithLogFormat:(NSString *)format dateTimeFormat:(NSString *)dateTimeFormat;
-(NSString *)formatLog:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function;
+(NSString *)defaultLogFormat;
+(instancetype)defaultLogFormatter;
@end
