//
//  BollingerBandCalculator.m
//  Indicators
//
//  Created by user on 24.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "BollingerBandCalculator.h"
#import "SMACalculator.h"

@interface BollingerBandCalculator()

@property (nonatomic, strong, readwrite) SMACalculator *smaCalc;
@property (nonatomic, assign, readwrite) double upDeviationMult;
@property (nonatomic, assign, readwrite) double downDeviationMult;

+ (NSArray *)calculateQuadricDeviationForNumbers:(NSArray *)numbers SMAs:(NSArray *)smaValues;

- (NSArray *)calculateStandartDevForQuadricDev:(NSArray *)quadricDeviations;

- (NSArray *)bollingerBandsForSMA:(NSArray *)smaValues standartDev:(NSArray *)standartDeviations;

@end

@implementation BollingerBandCalculator

@synthesize smaCalc, upDeviationMult, downDeviationMult;

-(id)initWithSMALength:(int)smaLength upDeviationMult:(double)upDevMult downDeviationMult:(double)downDevMult //desigated intializer
{
    self = [super init];
    if (self)
    {
        if (smaLength > 0)
            smaCalc = [[SMACalculator alloc] initWithAveragingIntervalLength:smaLength];
        else
            smaCalc = [[SMACalculator alloc] initWithAveragingIntervalLength:DEFAULT_BOLLINGER_SMA_LENGTH];
        
        if (upDevMult > 0)
            upDeviationMult = upDevMult;
        else
            upDeviationMult = DEFAULT_UP_DEV_MULT;
        
        if (downDevMult < 0)
            downDeviationMult = downDevMult;
        else
            downDeviationMult = DEFAULT_DOWN_DEV_MULT;
    }
    return self;
}

- (id)init
{
    return [self initWithSMALength:DEFAULT_BOLLINGER_SMA_LENGTH upDeviationMult:DEFAULT_UP_DEV_MULT downDeviationMult:DEFAULT_DOWN_DEV_MULT];
}


+ (NSArray *)calculateQuadricDeviationForNumbers:(NSArray *)numbers SMAs:(NSArray *)smaValues
{
    NSMutableArray *quadricDeviations = [NSMutableArray arrayWithCapacity:[numbers count]];
    NSNumber *number = nil;
    NSNumber *sma = nil;
    double deviation;
    
    
    NSEnumerator *numbersEnumerator = [numbers objectEnumerator];
    NSEnumerator *smasEnumerator = [smaValues objectEnumerator];
        
    while ( (number = [numbersEnumerator nextObject]) && 
            (sma = [smasEnumerator nextObject])  )
    {
        deviation = [number doubleValue] - [sma doubleValue];
        [quadricDeviations addObject:[NSNumber numberWithDouble:(deviation * deviation)]];
    }
        
    return quadricDeviations;
}

- (NSArray *)calculateStandartDevForQuadricDev:(NSArray *)quadricDeviations
{
    NSMutableArray *stdDeviations = [NSMutableArray arrayWithCapacity:[quadricDeviations count]];
    NSNumber *quadricDev = nil;
    double sum = 0;
    int quadricDevIndex = 0;
    int smaLength = self.smaCalc.averagingIntervalLength;
    
    for (quadricDev in quadricDeviations)
    {
        if ((quadricDevIndex + 1) < smaLength)
        {
            sum += [quadricDev doubleValue];
            [stdDeviations addObject:[NSNumber numberWithDouble:NAN]];
        } else if ((quadricDevIndex + 1) == smaLength)
        {
            sum += [quadricDev doubleValue];
            [stdDeviations addObject:[NSNumber numberWithDouble:sqrt(sum / smaLength)]];
        } else
        {
            sum += [quadricDev doubleValue];
            sum -= [[quadricDeviations objectAtIndex:(quadricDevIndex - smaLength)] doubleValue];
            [stdDeviations addObject:[NSNumber numberWithDouble:sqrt(sum / smaLength)]];
        }
        quadricDevIndex++;    
    }
    
    return stdDeviations;
}

- (NSArray *)bollingerBandsForSMA:(NSArray *)smaValues standartDev:(NSArray *)standartDeviations
{
    int numCount = [smaValues count];
    NSMutableArray *bollingerBands = [NSMutableArray arrayWithCapacity:numCount];
    int smaLength = self.smaCalc.averagingIntervalLength;
    double smaVal;
    double standartDev;
    double uppperDevMultiplier = self.upDeviationMult;
    double lowerDevMultiplier = self.downDeviationMult;
    for(int i = 0; i < numCount; i++)
    {
        if (i >= smaLength)
        {
            smaVal = [(NSNumber *)[smaValues objectAtIndex:i] doubleValue];
            standartDev = [(NSNumber *)[standartDeviations objectAtIndex:i] doubleValue];
            [bollingerBands addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithDouble:(smaVal + uppperDevMultiplier * standartDev)],@"upperband",
                                            [NSNumber numberWithDouble:smaVal],@"sma",
                                            [NSNumber numberWithDouble:(smaVal + lowerDevMultiplier * standartDev)],@"lowerband",
                                            nil ]];
        }
        else
        {
            [bollingerBands addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithDouble:NAN],@"upperband",
                                       [NSNumber numberWithDouble:NAN],@"sma",
                                       [NSNumber numberWithDouble:NAN],@"lowerband",
                                       nil ]];
        }   
    }
    return bollingerBands;
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    NSArray *smaValues = [self.smaCalc calculateExtendedMAForNumbers:numbers];
    
    NSArray *quadricDeviations = [BollingerBandCalculator calculateQuadricDeviationForNumbers:numbers SMAs:smaValues];
    
    NSArray *standartDeviations = [self calculateStandartDevForQuadricDev:quadricDeviations];
    
    NSArray * bollingerBands = [self bollingerBandsForSMA:smaValues standartDev:standartDeviations];
    
    return bollingerBands;
}

@end
