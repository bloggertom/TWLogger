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

-(instancetype)initWithFormat:(NSString *)format;
-(NSString *)formatLog:(TDWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method;
@end

#endif /* TWLogFormatterPrivate_h */
