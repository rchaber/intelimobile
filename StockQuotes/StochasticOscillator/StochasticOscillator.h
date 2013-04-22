//
//  StochasticOscillator.h
//  Indicators
//
//  Created by Edward Khorkov on 26.10.11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import "Indicator.h"
#import "StochasticsProtocol.h"
#import "AveragingType.h"

#define DEFAULT_K_PERIOD 14
#define DEFAULT_SLOWING_PERIOD 3
#define DEFAULT_D_PERIOD 3

@interface StochasticOscillator : Indicator <StochasticsProtocol>

@property (nonatomic, assign, readwrite, getter=kPeriod, setter = kPeriod:) int lookBackPeriod;
@property (nonatomic, assign, readwrite, getter = slowingPeriod, setter = slowingPeriod:) int firstSmoothingPeriod;
@property (nonatomic, assign, readwrite, getter=dPeriod, setter = dPeriod:) int secondSmoothingPeriod;

- (id)initWithLookBackPeriod:(int)lookBackPer 
        firstSmoothingPeriod:(int)firstSmoothingPer
       secondSmoothingPeriod:(int)secondSmoothingPer
               averagingType:(enum AveragingType)avType;

@end
