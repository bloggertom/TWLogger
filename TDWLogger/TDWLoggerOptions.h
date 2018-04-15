//
//  TDWLoggerOptions.h
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDWLoggerOptions : NSObject

@property (nonatomic, strong)NSURL *filePath;
@property (nonatomic, strong)NSDateComponents *pageLife;
@property (nonatomic)NSUInteger maxLogCacheCapacity;
@property (nonatomic)NSUInteger maxPageNum;
@property (nonatomic)NSString *logFilePrefix;

@end
