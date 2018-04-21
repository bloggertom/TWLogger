//
//  TWLoggerOptions.h
//  TDWLogger
//
//  Created by Thomas Wilson on 15/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWLoggerOptions : NSObject

@property (nonatomic, strong)NSString *filePath;
@property (nonatomic, strong)NSDateComponents *pageLife;
@property (nonatomic)NSUInteger maxPageSize;
@property (nonatomic)NSUInteger maxPageNum;
@property (nonatomic)NSString *logFilePrefix;

@end
