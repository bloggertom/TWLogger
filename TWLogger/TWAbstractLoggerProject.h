//
//  TWAbstractLoggerProject.h
//  TWLogger
//
//  Created by Thomas Wilson on 22/04/2018.
//  Copyright © 2018 Thomas Wilson. All rights reserved.
//

#ifndef TWAbstractLoggerProject_h
#define TWAbstractLoggerProject_h
#import "TWAbstractLogger.h"
#import "TWLogFormatter.h"

@interface TWAbstractLogger()

@property (nonatomic, readonly, strong)TWLogFormatter *logFormatter;

@end
#endif /* TWAbstractLoggerProject_h */
