//
//  TWLoggerTest.h
//  TWLogger
//
//  Created by Thomas Wilson on 02/05/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef TWLoggerTest_h
#define TWLoggerTest_h
#import <XCTest/XCTest.h>
#import "TWLogDelegate.h"
#import "TWAbstractLogger.h"

@interface TWLoggerTest : XCTestCase
@property (nonatomic, strong)TWLoggerOptions *options;
@property (nonatomic, strong)id<TWLoggerDelegate> logger;
@property (nonatomic, strong)NSFileManager *fileManager;
@property (nonatomic, strong)NSString *baseDir;
@property (nonatomic, strong)NSString *logPath;

-(NSString *)getLogDirPath;
-(void)setUpLogger;
-(NSArray *)contentsOfLogDir:(NSError **)error;
@end

#endif /* TWLoggerTest_h */
