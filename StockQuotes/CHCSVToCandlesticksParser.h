//
//  CHCVToCandlesticksParcer.h
//  StockQuotes
//
//  Created by Edward Khorkov on 10/7/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface CHCSVToCandlesticksParser : NSObject <CHCSVParserDelegate>

// returns array of Cantablesticks
// it is array of dictionaries with keys
// "min"
// "max"
// "open"
// "close"
+ (NSArray *)parseNSURL:(NSURL *)url;

@end
