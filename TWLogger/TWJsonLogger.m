//
//  TWJsonLogger.m
//  TWLogger
//
//  Created by Thomas Wilson on 06/10/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#import "TWJsonLogger.h"

@implementation TWJsonLogger

-(instancetype)init{
	TWLoggerOptions *options = [[TWLoggerOptions alloc]init];
	//defaults
	
	
	return [self initWithOptions:options];
}

-(void)logReceived:(TWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forFunction:(NSString *)function{
	
}

-(BOOL)startLogging{
	
}

-(void)stopLogging{
	
}

-(void)flushLogs{
	
}

@end
