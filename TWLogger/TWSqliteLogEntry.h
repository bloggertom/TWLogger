//
//  TWSqliteLogEntry.h
//  TWLogger
//
//  Created by Thomas Wilson on 29/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWLogLevel.h"

@interface TWSqliteLogEntry : NSObject

@property (nonatomic)NSInteger logId;
@property (nonatomic, strong)NSDate *datetime;
@property (nonatomic)TWLogLevel logLevel;
@property (nonatomic, strong)NSString *logBody;
@property (nonatomic, strong)NSString *file;
@property (nonatomic, strong)NSString *function;

@end
