//
//  TWSqliteLoggerTest.m
//  TWLoggerTests
//
//  Created by Thomas Wilson on 02/05/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWLoggerTest.h"
#import "TWSqliteLogger.h"
@interface TWSqliteLoggerTest : TWLoggerTest
@end

@implementation TWSqliteLoggerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)setUpLogger{
	self.logger = [[TWSqliteLogger alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
