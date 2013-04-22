//
//  SymbolStorage.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "SymbolStorage.h"

@implementation SymbolStorage
@synthesize symbolShortName;
@synthesize symbolLongName;
@synthesize symbolPriceNetChange;
@synthesize symbolPricePercentChange;
@synthesize symbolPrice;
@synthesize symbolBidSize;
@synthesize symbolBidPrice;
@synthesize symbolAskSize;
@synthesize symbolAskPrice;
@synthesize symbolOpenPrice;
@synthesize symbolHighPrice;
@synthesize symbolLowPrice;
@synthesize symbolPrevClosingPrice;
@synthesize symbolTradeVolume;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


@end
