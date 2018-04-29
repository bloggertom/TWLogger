//
//  TWSqliteLogEntry.h
//  TWLogger
//
//  Created by Thomas Wilson on 29/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATE_TIME_FORMAT @"yyyy-MM-dd-HH-mm-ss O"

@interface TWSqliteLogEntry : NSObject

@property (nonatomic)NSInteger logId;
@property (nonatomic)double timestamp;
@property (nonatomic, strong)NSString *datetime;
@property (nonatomic, strong)NSString* logLevel;
@property (nonatomic, strong)NSString *logBody;
@property (nonatomic, strong)NSString *file;
@property (nonatomic, strong)NSString *function;

@end
