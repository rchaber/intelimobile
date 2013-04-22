//
//  CandlesticksDrawer.h
//  Plot
//
//  Created by Edward Khorkov on 10/6/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CDUpperChartTypeSimpleMovingAverage,
    CDUpperChartTypeExponentalMovingAverage,
    CDUpperChartTypeBollingerBands
} CDUpperChartType;

typedef enum
{
    CDLowerChartTypeMACD,
    CDLowerChartTypeRSI,
    CDLowerChartTypeRSIStochastics
} CDLowerChartType;

@interface CandlesticksDrawer : NSObject
{
    NSMutableArray *candlesticks;
    CGRect rectangleToDrawIn;
    NSInteger numberOfCandlesticksOnScreen;
    float widthOfCandlestick;
    
    UIColor *scaleColor;
    UIColor *closeIsHigherThanOpenColor;
    UIColor *openIsHigherThanCloseColor;
    
    NSUInteger barsToRight;
}

// must be an array of dictionaries
// each dictionary must contain
// "min"
// "max"
// "open"
// "close"
// objects of which are NSStrings, with float number
// the first object is most recent
@property (nonatomic, copy) NSMutableArray *candlesticks;

@property (nonatomic, readonly) float widthOccupiedByCandle;

@property (nonatomic, strong) UIColor *scaleColor;
@property (nonatomic, strong) UIColor *closeIsHigherThanOpenColor;
@property (nonatomic, strong) UIColor *openIsHigherThanCloseColor;

@property (nonatomic, assign) NSUInteger barsToRight;

// designated initializer
- (id)initWithRectangleToDrawIn:(CGRect)rectangle numberOfCandlesticksOnScreen:(NSInteger)number;

- (void)drawCandlesticksInRangeFrom:(NSRange)range;
- (void)drawBarStockInRangeFrom:(NSRange)range;
- (void)drawLinesInRangeFrom:(NSRange)range;
- (void)drawAreaInRangeFrom:(NSRange)range;

- (void)addUpperStudyToDraw:(CDUpperChartType)chartType withOptions:(NSDictionary *)options;
- (void)removeAllUpperStudies;

- (void)setLowerStudyToDraw:(CDLowerChartType)chartType withOptions:(NSDictionary *)options;
- (void)removeLowerStudy;

@end
