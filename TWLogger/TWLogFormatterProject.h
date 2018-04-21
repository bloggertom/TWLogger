//
//  TWLogFormatterPrivate.h
//  TWLogger
//
//  Created by Thomas Wilson on 21/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef TWLogFormatterPrivate_h
#define TWLogFormatterPrivate_h
#import	"TWLogFormatter.h"
#import	"TWLogLevel.h"

@interface TWLogFormatter : NSObject

@property (nonatomic, strong)NSString *format;
@property (nonatomic, strong)NSString *dateTimeFormat;
-(instancetype)initWithLogFormat:(NSString *)format;
-(instancetype)initWithLogFormat:(NSString *)format dateTimeFormat:(NSString *)dateTimeFormat;
-(NSString *)formatLog:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method;
+(NSString *)defaultLogFormat;
@end

#endif /* TWLogFormatterPrivate_h */
