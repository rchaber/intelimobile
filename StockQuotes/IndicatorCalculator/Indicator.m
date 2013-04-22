//
//  Indicator.m
//  Indicators
//
//  Created by Edward Khorkov on 25.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "Indicator.h"

@interface Indicator()

+ (NSArray *)readNumbersFromDataArray:(NSArray *)data forValueNamed:(NSString *)valueName;

+ (NSArray *)readTriplesOfNumbersFromDataArray:(NSArray *)data
                                                highValueName:(NSString *)firstName
                                                     currentValueName:(NSString *)secondName
                                                     lowValueName:(NSString *)thirdName;

- (NSArray *)calculateFromEarlyToLate:(NSArray *)numbers;

- (NSArray *)calculateFromLateToEarly:(NSArray *)numbers;

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers;

@end

@implementation Indicator

+ (NSNumber *)valueFromDictionary:(NSDictionary *)dictionay forName:(NSString *)name
{
    NSString *objectStringRepresentation = [dictionay objectForKey:name];
    double currentValue = [objectStringRepresentation doubleValue];
    return [NSNumber numberWithDouble:currentValue];
}

+ (NSArray *)readNumbersFromDataArray:(NSArray *)data forValueNamed:(NSString *)valueName
{
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:[data count]];
    
    NSDictionary *dataElement = nil;
    for (dataElement in data)
    {
        [numbers addObject:[Indicator valueFromDictionary:dataElement forName:valueName]];
    }
    
    return numbers;
}

+ (NSArray *)readTriplesOfNumbersFromDataArray:(NSArray *)data
                                 highValueName:(NSString *)firstName
                              currentValueName:(NSString *)secondName
                                  lowValueName:(NSString *)thirdName
{
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:[data count]];
    
    NSDictionary *dataElement = nil;
    for (dataElement in data)
    {
        [numbers addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [Indicator valueFromDictionary:dataElement forName:firstName], @"high",
                                            [Indicator valueFromDictionary:dataElement forName:secondName], @"current",
                                            [Indicator valueFromDictionary:dataElement forName:thirdName], @"low",
                                            nil]];
    }
    
    return numbers;
}

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers
{
    //TODO - throw an Exception there
    return nil;
}

- (NSArray *)calculateFromEarlyToLate:(NSArray *)numbers
{
    return [self calculateArrayOfIndicatorsFromNumbers:numbers];    
}

- (NSArray *)calculateFromLateToEarly:(NSArray *)numbers
{
    numbers = [[numbers reverseObjectEnumerator] allObjects];
    numbers = [self calculateArrayOfIndicatorsFromNumbers:numbers];
    return [[numbers reverseObjectEnumerator] allObjects];
}

- (NSArray *)calculateForDataArray:(NSArray *)data forValueNamed:(NSString *)valueName ordered:(enum InputDataOrder)order
{
    NSArray *numbers = [Indicator readNumbersFromDataArray:data forValueNamed:valueName];
    
    if (order == FROM_EARLY_TO_LATE)
    {
        return [self calculateFromEarlyToLate:numbers];
    }
    else if (order == FROM_LATE_TO_EARLY)
    {
        return [self calculateFromLateToEarly:numbers];
    }
    else
        return nil;
}

- (NSArray *)calculateForDataArray:(NSArray *)data
                   forHighValueNamed:(NSString *)highValName
                   currentValueNamed:(NSString *)currenrValName
                       lowValueNamed:(NSString *)lowValName
                           ordered:(enum InputDataOrder)order;
{
    NSArray *numbers = [Indicator readTriplesOfNumbersFromDataArray:data
                                                      highValueName:highValName 
                                                    currentValueName:currenrValName 
                                                        lowValueName:lowValName];
    
    if (order == FROM_EARLY_TO_LATE)
    {
        return [self calculateFromEarlyToLate:numbers];
    }
    else if (order == FROM_LATE_TO_EARLY)
    {
        return [self calculateFromLateToEarly:numbers];
    }
    else
        return nil;
}


@end
