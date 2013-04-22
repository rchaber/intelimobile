//
//  SymbolStorage.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SymbolStorage : NSObject
{
    NSString *symbolShortName;
    NSString *symbolLongName;
    NSString *symbolPriceNetChange;
    NSString *symbolPricePercentChange;
    NSString *symbolPrice;
    NSString *symbolBidSize;
    NSString *symbolBidPrice;
    NSString *symbolAskSize;
    NSString *symbolAskPrice;
    NSString *symbolOpenPrice;
    NSString *symbolHighPrice;
    NSString *symbolLowPrice;
    NSString *symbolPrevClosingPrice;
    NSString *symbolTradeVolume;
}

@property (nonatomic, copy) NSString *symbolShortName;
@property (nonatomic, copy) NSString *symbolLongName;
@property (nonatomic, copy) NSString *symbolPriceNetChange;
@property (nonatomic, copy) NSString *symbolPricePercentChange;
@property (nonatomic, copy) NSString *symbolPrice;
@property (nonatomic, copy) NSString *symbolBidSize;
@property (nonatomic, copy) NSString *symbolBidPrice;
@property (nonatomic, copy) NSString *symbolAskSize;
@property (nonatomic, copy) NSString *symbolAskPrice;
@property (nonatomic, copy) NSString *symbolOpenPrice;
@property (nonatomic, copy) NSString *symbolHighPrice;
@property (nonatomic, copy) NSString *symbolLowPrice;
@property (nonatomic, copy) NSString *symbolPrevClosingPrice;
@property (nonatomic, copy) NSString *symbolTradeVolume;

@end
