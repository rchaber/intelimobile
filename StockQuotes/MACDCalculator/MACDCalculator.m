//
//  MACDCalculator.m
//  Indicators
//
//  Created by Edward Khorkov on 25.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "MACDCalculator.h"
#import "SMACalculator.h"
#import "EMACalculator.h"
#import "MACalcProtocol.h"

@interface MACDCalculator()

@property (nonatomic, strong, readwrite) Indicator <MACalcProtocol> *movingAverageCalc;

- (NSArray *)macdFromNumbers:(NSArray *)numbers;

- (NSArray *)signalLineFromMACDValues:(NSArray *)macdValues;

- (NSArray *)signalLineFromMACDValues:(NSArray *)macdValues;

@end

@implementation MACDCalculator

@synthesize macdAveragingLength, fastAveragingLength, slowAveragingLength, movingAverageCalc;

- (void)setFastAveragingLength:(int)fastAvLength
{
    if (fastAvLength > 0)
        fastAveragingLength = fastAvLength;
    else
        fastAveragingLength = DEFAULT_FAST_LENGTH;
}

- (void)setSlowAveragingLength:(int)slowAvLength
{
    if (slowAvLength > 0)
        slowAveragingLength = slowAvLength;
    else
        slowAveragingLength = DEFAULT_SLOW_LENGTH;
}

- (void)setMACDAveragingLength:(int)macdAvLength
{
    if (macdAvLength > 0)
        macdAveragingLength = macdAvLength;
    else
        macdAveragingLength = DEFAULT_MACD_LENGTH;
}

- (void) setMovingAverageType:(enum AveragingType)type
{
    if (type == SMA)
    {
        self.movingAverageCalc = nil;
        movingAverageCalc = [[SMACalculator alloc] initWithAveragingIntervalLength:self.fastAveragingLength];
    }
    else if (type == EMA)
    {
        self.movingAverageCalc = nil;
        movingAverageCalc = [[EMACalculator alloc] initWithAveragingIntervalLength:self.fastAveragingLength];
    }
}

- (id)initWithMACDLength:(int)macdLength fastLength:(int)fastLength slowLength:(int)slowLength averagingType:(enum AveragingType)avType
{
    self = [super init];
    if (self)
    {
        if (macdLength > 0)
            macdAveragingLength = macdLength;
        else
            macdAveragingLength = DEFAULT_MACD_LENGTH;
        if (fastLength > 0)
            fastAveragingLength = fastLength;
        else
            fastAveragingLength = DEFAULT_FAST_LENGTH;
        if (slowLength > 0)
            slowAveragingLength = slowLength;
        else
            slowAveragingLength = DEFAULT_SLOW_LENGTH;
        
        if (avType == SMA)
            [self setMovingAverageType:SMA];
        else if (avType == EMA)
            [self setMovingAverageType:EMA];
        else
            return nil;
    }
    return self;
}

- (id)init
{
    return [self initWithMACDLength:DEFAULT_MACD_LENGTH fastLength:DEFAULT_FAST_LENGTH slowLength:DEFAULT_SLOW_LENGTH averagingType:EMA];
}


- (NSArray *)macdFromNumbers:(NSArray *)numbers
{
    [self.movingAverageCalc setAveragingIntervalLength:self.fastAveragingLength];
    NSArray *fastMAValues = [self.movingAverageCalc calculateArrayOfIndicatorsFromNumbers:numbers];
    [self.movingAverageCalc setAveragingIntervalLength:self.slowAveragingLength];
    NSArray *slowMAValues = [self.movingAverageCalc calculateArrayOfIndicatorsFromNumbers:numbers];
    
    NSMutableArray * macdValues = [NSMutableArray arrayWithCapacity:[numbers count]];
    
    NSEnumerator *fastMAEnumerator = [fastMAValues objectEnumerator];
    NSEnumerator *slowMAEnumerator = [slowMAValues objectEnumerator];
    
    NSNumber *fastMAVal = nil;
    NSNumber *slowMAVal = nil;
    
    while ( (fastMAVal = [fastMAEnumerator nextObject]) && (slowMAVal = [slowMAEnumerator nextObject]) )
    {
        [macdValues addObject:[NSNumber numberWithDouble:([fastMAVal doubleValue] - [slowMAVal doubleValue])]];    
    }
    
    return macdValues;
}

- (NSArray *)signalLineFromMACDValues:(NSArray *)macdValues
{
    NSMutableArray *signalLineValues = [NSMutableArray arrayWithCapacity:[macdValues count]];
    
    int actualMACDMAStartIndex = self.slowAveragingLength - 1;
    for (int i = 0; i < actualMACDMAStartIndex; i++)
    {
        [signalLineValues addObject:[NSNumber numberWithDouble:NAN]];
    }
            
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(actualMACDMAStartIndex, [macdValues count] - actualMACDMAStartIndex)];
    
    [self.movingAverageCalc setAveragingIntervalLength:self.macdAveragingLength];
    NSArray * smothMACDs = [self.movingAverageCalc calculateArrayOfIndicatorsFromNumbers:[macdValues objectsAtIndexes:indexSet]];
    [signalLineValues addObjectsFromArray:smothMACDs];
    
    return signalLineValues;
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    NSArray * macdValues = [self macdFromNumbers:numbers];
    
    NSArray *signalLineValues = [self signalLineFromMACDValues:macdValues];
    
    NSEnumerator *macdValuesEnum = [macdValues objectEnumerator];
    NSEnumerator *signalValuesEnum = [signalLineValues objectEnumerator];
    
    NSNumber *macdVal = nil;
    NSNumber *signalVal = nil;    
    
    NSMutableArray *returnVals = [NSMutableArray arrayWithCapacity:[macdValues count]];
    
    while ( (macdVal = [macdValuesEnum nextObject]) && (signalVal = [signalValuesEnum nextObject]) )
    {
        [returnVals addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        macdVal, @"macd",
                                        signalVal, @"signal",
                                        [NSNumber numberWithDouble:([macdVal doubleValue] - [signalVal doubleValue])],@"histogram", nil]];
    }
    
    return returnVals;
}

@end
