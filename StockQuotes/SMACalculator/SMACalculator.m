//
//  EMACalculator.h
//  Indicators
//
//  Created by Edward Khorkov on 20.10.11.
//  Copyright 2011 Polecat. All rights reserved.
// 

#import "SMACalculator.h"

@interface SMACalculator()

+ (double)nanOrInfToZeroFilter:(double)value;

@end

@implementation SMACalculator

@synthesize averagingIntervalLength;

- (id)initWithAveragingIntervalLength:(int)initAveragingIntervalLength //desigated intializer
{
    self = [super init];
    if (self)
    {
        if (initAveragingIntervalLength > 0)
            self.averagingIntervalLength = initAveragingIntervalLength;
        else
            self.averagingIntervalLength = DEFAULT_SMA_LENGTH;
    }
        return self;
}

- (id)init
{
    return [self initWithAveragingIntervalLength:DEFAULT_SMA_LENGTH];
}

+ (NSNumber *)calculateForNumbers:(NSArray *)numbers
{
    int averagingIntervalLength = [numbers count];
    if (averagingIntervalLength > 0)
    {
        double accumulator = 0;
        NSNumber *number = nil;
        for (number in numbers)
        {
            accumulator += [SMACalculator nanOrInfToZeroFilter:[number doubleValue]];       
        }
        return [NSNumber numberWithDouble:(accumulator / averagingIntervalLength)];  
    }
    else   
        return [NSNumber numberWithDouble:NAN];;
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    NSMutableArray *smaForNumbers = [[NSMutableArray alloc] initWithCapacity:[numbers count]];
    
    NSNumber *number = nil;
    int numberIndex = 0;
    double accumulator = 0;
    double notNANnotINFnumber;
    for (number in numbers)
    {
        notNANnotINFnumber = [SMACalculator nanOrInfToZeroFilter:[number doubleValue]];
                       
        if ((numberIndex + 1) < self.averagingIntervalLength)
        {
            accumulator += notNANnotINFnumber;
            [smaForNumbers addObject:[NSNumber numberWithDouble:NAN]];
        } else if((numberIndex + 1) == self.averagingIntervalLength)
        {
            accumulator += notNANnotINFnumber;
            [smaForNumbers addObject:[NSNumber numberWithDouble:(accumulator / self.averagingIntervalLength)]];
        }else
        {
            accumulator += notNANnotINFnumber;
            accumulator -= [SMACalculator nanOrInfToZeroFilter:[[numbers objectAtIndex:(numberIndex - self.averagingIntervalLength)] doubleValue]];
           [smaForNumbers addObject:[NSNumber numberWithDouble:(accumulator / self.averagingIntervalLength)]];
        }
        numberIndex++;
    }
    
    return smaForNumbers;    
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
