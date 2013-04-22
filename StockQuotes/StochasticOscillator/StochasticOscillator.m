//
//  StochasticOscillator.m
//  Indicators
//
//  Created by Edward Khorkov on 26.10.11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import "StochasticOscillator.h"
#import "MACalcProtocol.h"
#import "SMACalculator.h"
#import "EMACalculator.h"

@interface StochasticOscillator()

@property (nonatomic, strong, readwrite) Indicator <MACalcProtocol> *movingAverageCalc;

@end

@implementation StochasticOscillator

@synthesize  lookBackPeriod, firstSmoothingPeriod, secondSmoothingPeriod, movingAverageCalc;

- (void)setMovingAverageType:(enum AveragingType)type
{
    if (type == SMA)
    {
        movingAverageCalc = [[SMACalculator alloc] initWithAveragingIntervalLength:self.firstSmoothingPeriod];
    }
    else if (type == EMA)
    {
        movingAverageCalc = [[EMACalculator alloc] initWithAveragingIntervalLength:self.firstSmoothingPeriod];
    }
    else
        self.movingAverageCalc = nil;
}

- (id)initWithLookBackPeriod:(int)lookBackPer 
        firstSmoothingPeriod:(int)firstSmoothingPer
       secondSmoothingPeriod:(int)secondSmoothingPer
               averagingType:(enum AveragingType)avType
{
    self = [super init];
    if (self)
    {
        if (lookBackPer > 0)
            lookBackPeriod = lookBackPer;
        else
            lookBackPeriod = DEFAULT_K_PERIOD;
        if (firstSmoothingPer > 0)
           firstSmoothingPeriod = firstSmoothingPer;
        else
            firstSmoothingPeriod = DEFAULT_SLOWING_PERIOD;
        if (secondSmoothingPer > 0)
            secondSmoothingPeriod = secondSmoothingPer;
        else
            secondSmoothingPeriod = DEFAULT_D_PERIOD;
        
        [self setMovingAverageType:avType];   
    }
    
    return self;
}

- (id)init
{
    return [self initWithLookBackPeriod:DEFAULT_K_PERIOD
                   firstSmoothingPeriod:DEFAULT_SLOWING_PERIOD
                  secondSmoothingPeriod:DEFAULT_D_PERIOD
                          averagingType:SMA];
}


+ (NSNumber *)maxAtArray:(NSArray *)values
{
    double maxValue = [[values objectAtIndex:0] doubleValue];
    NSEnumerator *valuesEnum = [values objectEnumerator];
    NSNumber *currentValue = nil;
    
    while ((currentValue = [valuesEnum nextObject]))
    {
        if(maxValue < [currentValue doubleValue])
        {
            maxValue = [currentValue doubleValue];
        }
    }
    
   return [NSNumber numberWithDouble:maxValue];
}

+ (NSNumber *)minAtArray:(NSArray *)values
{
    double minValue = [[values objectAtIndex:0] doubleValue];
    NSEnumerator *valuesEnum = [values objectEnumerator];
    NSNumber *currentValue = nil;
    
    while ((currentValue = [valuesEnum nextObject]))
    {
        if(minValue > [currentValue doubleValue])
        {
            minValue = [currentValue doubleValue];
        }
    }
    return [NSNumber numberWithDouble:minValue];
}


- (NSArray *)highForValues:(NSArray *)values
{
    NSMutableArray *highestHighValues = [NSMutableArray arrayWithCapacity:[values count]];
      
    NSMutableArray *portion = [[NSMutableArray alloc] init];
    
    NSEnumerator *valuesEnum = [values objectEnumerator];
    NSNumber *max = nil;
    NSNumber *currentValue = nil;
    int index = 0;
    while ((currentValue = [valuesEnum nextObject]))
    {
        
        if ( index < self.lookBackPeriod )
        {
            [portion addObject:currentValue];
            max = [StochasticOscillator maxAtArray:portion];
            [highestHighValues addObject:max];
        }
        else
        {
            [portion removeObjectAtIndex:0];
            [portion addObject:currentValue];
            max = [StochasticOscillator maxAtArray:portion];
            [highestHighValues addObject:max];        
        }
        index++;
    }
    
    
    return highestHighValues;   
}

- (NSArray *)lowForValues:(NSArray *)values
{
    NSMutableArray *lowestLowValues = [NSMutableArray arrayWithCapacity:[values count]];
    
    NSMutableArray *portion = [[NSMutableArray alloc] init];
                               
    NSEnumerator *valuesEnum = [values objectEnumerator];
    NSNumber *currentValue = nil;
    NSNumber *min = nil;
    int index = 0;
    while ((currentValue = [valuesEnum nextObject]))
    {
        
        if ( index < self.lookBackPeriod )
        {
            [portion addObject:currentValue];
            min = [StochasticOscillator minAtArray:portion];
            [lowestLowValues addObject:min];
        }
        else
        {
            [portion removeObjectAtIndex:0];
            [portion addObject:currentValue];
            min = [StochasticOscillator minAtArray:portion];
            [lowestLowValues addObject:min];        
        }
        index++;
    }
    
    
    return lowestLowValues;   
}

+ (NSArray *)calculate_K_IndexForCurrent:(NSArray *)currentValues highestHight:(NSArray *)highestValues lowestLow:(NSArray *)lowestValues
{
    NSMutableArray * kIndex = [NSMutableArray arrayWithCapacity:[currentValues count]];
    
    NSEnumerator *curValsEnum = [currentValues objectEnumerator];
    NSEnumerator *highestValsEnum = [highestValues objectEnumerator];
    NSEnumerator *lowestValsEnum = [lowestValues objectEnumerator];
    
    NSNumber *curVal, *highVal, *lowVal;
    while ( (curVal = [curValsEnum nextObject]) && 
            (highVal = [highestValsEnum nextObject]) &&
            (lowVal = [lowestValsEnum nextObject])
           )
    {
        [kIndex addObject:[NSNumber numberWithDouble:( 
                                   100 * ( [curVal doubleValue] - [lowVal doubleValue])/([highVal doubleValue] - [lowVal doubleValue]) 
                                                      )]];
    }

    return kIndex;   
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    NSMutableArray *highPrices = [NSMutableArray arrayWithCapacity:[numbers count]];
    NSMutableArray *lowPrices = [NSMutableArray arrayWithCapacity:[numbers count]];
    NSMutableArray *currentPrices = [NSMutableArray arrayWithCapacity:[numbers count]];
    
    NSEnumerator *numbersEnumerator = [numbers objectEnumerator];
    NSDictionary *highCurrentLowTriple = nil; 
    
    while ( (highCurrentLowTriple = [numbersEnumerator nextObject]) )
    {
        [highPrices addObject:[highCurrentLowTriple objectForKey:@"high"]];
        [currentPrices addObject:[highCurrentLowTriple objectForKey:@"current"]];
        [lowPrices addObject:[highCurrentLowTriple objectForKey:@"low"]];        
    }
    
    NSArray *highestHighPrices = [self highForValues:highPrices];
    NSArray *lowestLowPrices = [self lowForValues:lowPrices];
       
    NSArray *kIndex = [StochasticOscillator calculate_K_IndexForCurrent:currentPrices highestHight:highestHighPrices lowestLow:lowestLowPrices];
    
    [self.movingAverageCalc setAveragingIntervalLength:self.firstSmoothingPeriod];
    NSArray *full_K_Index = [self.movingAverageCalc calculateExtendedMAForNumbers:kIndex];
    
    [self.movingAverageCalc setAveragingIntervalLength:self.secondSmoothingPeriod];
    NSArray *full_D_Index = [self.movingAverageCalc calculateExtendedMAForNumbers:full_K_Index];
    
    
    NSMutableArray *returnedVals = [NSMutableArray arrayWithCapacity:[full_K_Index count]];
    
    NSEnumerator *full_K_IndexEnum = [full_K_Index objectEnumerator];
    NSEnumerator *full_D_IndexEnum = [full_D_Index objectEnumerator];
    NSNumber *full_K_IndexVal, *full_D_IndexVal;
    
    int first_k_correctIndex = self.lookBackPeriod + self.firstSmoothingPeriod - 1;
    int first_d_correctIndex = self.lookBackPeriod + self.firstSmoothingPeriod + self.secondSmoothingPeriod - 1;
    int counter = 0;
    while ( (full_K_IndexVal = [full_K_IndexEnum nextObject]) &&
            (full_D_IndexVal = [full_D_IndexEnum nextObject]) )
    {
        [returnedVals addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                 full_K_IndexVal, @"full_k",
                                 full_D_IndexVal, @"full_d",
                                 (counter < first_k_correctIndex) ? @"no" : @"yes", @"k_correctness",
                                 (counter < first_d_correctIndex) ? @"no" : @"yes", @"d_correctness",
                                 nil]];
        counter++;
    }
    
    return returnedVals;       
}

@end

