//
//  RSICalculator.m
//  Indicators
//
//  Created by Edward Khorkov on 25.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "RSICalculator.h"

@interface RSICalculator()

+ (NSArray *)calculateGainsForPrices:(NSArray *)prices;

+ (NSArray *)calculateLossesForPrices:(NSArray *)prices;

- (NSArray *)calculateAverage:(NSArray *)values;

+ (NSArray *)calculateRSIFromAverageGains:(NSArray *)gains averageLosses:(NSArray *)losses;

@end

@implementation RSICalculator

@synthesize averagingIntervalLength;

- (id)initWithAveragingIntervalLength:(int)length // designated initializer
{
    self = [super init];
    if (self)
    {
        if (length > 0)
            averagingIntervalLength = length;
        else
            averagingIntervalLength = DEFAULT_RSI_AVERAGING_LENGTH;
    }
    return self;
}

- (id)init
{
    return [self initWithAveragingIntervalLength:DEFAULT_RSI_AVERAGING_LENGTH];
}

+ (NSArray *)calculateGainsForPrices:(NSArray *)prices
{
    NSMutableArray *gains = [NSMutableArray arrayWithCapacity:[prices count]];
    [gains addObject:[NSDecimalNumber zero]];
    
    NSEnumerator *priceEnumerator = [prices objectEnumerator];
    NSNumber *currentPrice = [priceEnumerator nextObject];
    double previousPrice = [currentPrice doubleValue];
    double priceDelta = 0;
    while ((currentPrice = [priceEnumerator nextObject]))
    {
        if((priceDelta = [currentPrice doubleValue] - previousPrice) > 0)
            [gains addObject:[NSDecimalNumber numberWithDouble:priceDelta]];
        else
            [gains addObject:[NSDecimalNumber zero]];
        previousPrice = [currentPrice doubleValue];
    }
        
    return gains;
}


+ (NSArray *)calculateLossesForPrices:(NSArray *)prices
{
    NSMutableArray *losses = [NSMutableArray arrayWithCapacity:[prices count]];
    [losses addObject:[NSDecimalNumber zero]];
    
    NSEnumerator *priceEnumerator = [prices objectEnumerator];
    NSNumber *currentPrice = [priceEnumerator nextObject];
    double previousPrice = [currentPrice doubleValue];
    double priceDelta = 0;
    while ((currentPrice = [priceEnumerator nextObject]))
    {
        if((priceDelta = [currentPrice doubleValue] - previousPrice) < 0)
            [losses addObject:[NSDecimalNumber numberWithDouble:(- priceDelta)]];
        else
            [losses addObject:[NSDecimalNumber zero]];
        previousPrice = [currentPrice doubleValue];
    }
    
    return losses;
}

- (NSArray *)calculateAverage:(NSArray *)values
{
    NSMutableArray *averageValues = [NSMutableArray arrayWithCapacity:[values count]];
    int averagingLength = self.averagingIntervalLength;
    
    NSEnumerator *valueEnumerator = [values objectEnumerator];
    NSNumber *elem = nil;
    double previousAverageVal = 0;
    int counter = 0;
    
    while ((elem = [valueEnumerator nextObject])  && counter < averagingLength)
    {
        [averageValues addObject:[NSNumber numberWithDouble:NAN]];
        previousAverageVal += [elem doubleValue];
        counter++;
    }
    
    previousAverageVal /= averagingLength;
    
    while ((elem = [valueEnumerator nextObject]))
    {
        previousAverageVal = (previousAverageVal * (averagingLength - 1) + [elem doubleValue]) / 14;
        [averageValues addObject:[NSNumber numberWithDouble:previousAverageVal]];    
    }
       
    return averageValues;
}

+ (NSArray *)calculateRSIFromAverageGains:(NSArray *)gains averageLosses:(NSArray *)losses
{
    NSMutableArray *rsiValues = [NSMutableArray arrayWithCapacity:[gains count]];
    
    NSEnumerator *gainsEnumerator = [gains objectEnumerator];
    NSEnumerator *lossesEnumerator = [losses objectEnumerator];
    NSDecimalNumber *gain = nil;
    NSDecimalNumber *loss = nil;
    
    double relativeStrength;
    double relativeStrengthIndex;
    
    while ((gain = [gainsEnumerator nextObject]) && (loss = [lossesEnumerator nextObject]))
    {
        if ([gain compare:[NSDecimalNumber zero]] == NSOrderedSame)
            relativeStrengthIndex = 0;
        else if ([loss compare:[NSDecimalNumber zero]] == NSOrderedSame)
            relativeStrengthIndex = 100;
        else
        {
            relativeStrength = [gain doubleValue] / [loss doubleValue];
            relativeStrengthIndex = 100 - 100 / (1 + relativeStrength);
        }
        [rsiValues addObject:[NSNumber numberWithDouble:relativeStrengthIndex]];   
    }
    
    return rsiValues;
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    NSArray *losses = [RSICalculator calculateLossesForPrices:numbers];
    NSArray *gains = [RSICalculator calculateGainsForPrices:numbers];
    
    NSArray *averageLosses = [self calculateAverage:losses];
    NSArray *averageGains = [self calculateAverage:gains];
    
    NSArray *rsiValues = [RSICalculator calculateRSIFromAverageGains:averageGains averageLosses:averageLosses];
        
    return rsiValues;
}

@end
