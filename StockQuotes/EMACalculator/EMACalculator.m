//
//  EMACalculator.m
//  Indicators
//
//  Created by Edvard Khorkov  on 21.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "EMACalculator.h"
#import "SMACalculator.h"

@interface EMACalculator()

+ (double)nanOrInfToZeroFilter:(double)value;

@end

@implementation EMACalculator

@synthesize averagingIntervalLength;

- (id)initWithAveragingIntervalLength:(int)initAveragingIntervalLength
{
    self = [super init];
    if (self)
    {
        if (initAveragingIntervalLength > 0)
            self.averagingIntervalLength = initAveragingIntervalLength;
        else
            self.averagingIntervalLength = DEFAULT_EMA_LENGTH;
    }
    return self;
}

- (id)init
{
   return [self initWithAveragingIntervalLength:DEFAULT_EMA_LENGTH];  
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    NSMutableArray *emaForNumbers = [[NSMutableArray alloc] initWithCapacity:[numbers count]];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.averagingIntervalLength)];

    NSNumber *startSMA = [SMACalculator calculateForNumbers:[numbers objectsAtIndexes:indexSet]];
    
    
//    NSLog(@"startSMA %@\n", startSMA);
    
    double multiplier = 2 / (double)(self.averagingIntervalLength + 1);
    
    NSNumber *number = nil;
    double previousEMA = 0;
    double currentEMA = 0;
    int numberIndex = 0;    
    for (number in numbers)
    {
        if ((numberIndex + 1) < self.averagingIntervalLength)
        {
            [emaForNumbers addObject:[NSNumber numberWithDouble:NAN]];
        } else if ((numberIndex + 1) == self.averagingIntervalLength)
        {
            [emaForNumbers addObject:startSMA];
            previousEMA = [startSMA doubleValue];
        } else
        {
            currentEMA = ([EMACalculator nanOrInfToZeroFilter:([number doubleValue])] - previousEMA) * multiplier + previousEMA;
//            NSLog(@"currentEMA %g\n", currentEMA);
            [emaForNumbers addObject:[NSNumber numberWithDouble:currentEMA]];
            previousEMA = currentEMA;
        }
        numberIndex++;
    }
    
    return emaForNumbers;    
}

- (NSArray *)calculateExtendedMAForNumbers:(NSArray *)numbers
{   
    NSMutableArray *smaValues = [NSMutableArray arrayWithArray:[self calculateArrayOfIndicatorsFromNumbers:numbers]];
    
    int firstIndexOfNotNan = self.averagingIntervalLength - 1;
    
    NSNumber *firstNotNANValue = [smaValues objectAtIndex:firstIndexOfNotNan];
    
    for (int i = 0; i < firstIndexOfNotNan; i++)
    {
        [smaValues replaceObjectAtIndex:i withObject:firstNotNANValue];
    }
    
    return smaValues;   
}

#pragma mark - utility methods

+ (double)nanOrInfToZeroFilter:(double)value
{
    if (isnan(value) || isinf(value))
        return 0;
    else
        return value;
}


@end
