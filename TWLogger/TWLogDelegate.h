//
//  LogDelegate.h
//  TDWLogger
//
//  Created by Thomas Wilson on 09/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef LogDelegate_h
#define LogDelegate_h
#import	<Foundation/Foundation.h>
#import "TWLogLevel.h"

@protocol TWLoggerDelegate <NSObject>
@property (nonatomic, getter=isLogging)BOOL logging;
-(void)logReceived:(TDWLogLevel)level body:(NSString *)body fromFile:(NSString *)file forMethod:(NSString *)method;
-(void)stopLogging;
@end
#endif /* LogDelegate_h */
