//
//  MACalcProtocol.h
//  Indicators
//
//  Created by Edward Khorkov on 26.10.11.
//  Copyright (c) Polecat. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol MACalcProtocol

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers;

- (void)setAveragingIntervalLength:(int)averagingIntervalLength;

- (NSArray *)calculateExtendedMAForNumbers:(NSArray *)numbers;

@optional

+ (NSNumber *)calculateForNumbers:(NSArray *)numbers;

@end