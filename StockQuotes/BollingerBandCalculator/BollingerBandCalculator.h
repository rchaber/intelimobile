//
//  BollingerBandCalculator.h
//  Indicators
//
//  Created by user on 24.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "Indicator.h"
#import "IndicatorCalcProtocol.h"

#define DEFAULT_UP_DEV_MULT 2.0
#define DEFAULT_DOWN_DEV_MULT -2.0
#define DEFAULT_BOLLINGER_SMA_LENGTH 20

@interface BollingerBandCalculator : Indicator <IndicatorCalcProtocol>

-(id)initWithSMALength:(int)smaLength upDeviationMult:(double)upDevMult downDeviationMult:(double)downDevMult; //desigated intializer

@end
