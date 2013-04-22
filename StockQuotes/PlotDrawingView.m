//
//  PlotView.m
//  Plot
//
//  Created by Edward Khorkov on 10/6/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "PlotDrawingView.h"
#import "PlotDrawer.h"

#define NUMBER_OF_CANDLESTICKS_ON_SCREEN 60

typedef enum 
{
    ObjectToDrawBar,
    ObjectToDrawCandle,
    ObjectToDrawLine,
    ObjectToDrawArea
}ObjectToDraw;

@interface PlotDrawingView() 
{
    ObjectToDraw objectToDraw;
}
@end

@implementation PlotDrawingView

@synthesize candlestickDrawer;
@synthesize rangeToDraw;
@synthesize barsToRight;

- (void)setRangeToDraw:(NSRange)newRangeToDraw
{
    int location = newRangeToDraw.location;
    if (location >= [self.candlestickDrawer.candlesticks count] - newRangeToDraw.length) {
        newRangeToDraw.location = [self.candlestickDrawer.candlesticks count] - newRangeToDraw.length - 1;
    }
    if (location < 0) {
        newRangeToDraw.location = 0;
    }
    newRangeToDraw.length = NUMBER_OF_CANDLESTICKS_ON_SCREEN;
    
    rangeToDraw = newRangeToDraw;
}

- (void)setBarsToRight:(NSUInteger)bToRight
{
    barsToRight = bToRight;
    self.candlestickDrawer.barsToRight = bToRight;
}

- (CandlesticksDrawer *)candlestickDrawer
{
    if (!candlestickDrawer) {
        candlestickDrawer = [[CandlesticksDrawer alloc] initWithRectangleToDrawIn:self.bounds numberOfCandlesticksOnScreen:NUMBER_OF_CANDLESTICKS_ON_SCREEN];
        candlestickDrawer.scaleColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1];
    }
    return candlestickDrawer;
}

- (void)setCandlesticks:(NSMutableArray *)cs
{
    self.candlestickDrawer.candlesticks = cs;
    [self setNeedsDisplay];
}

- (void)drawBars
{
    objectToDraw = ObjectToDrawBar;
    [self setNeedsDisplay];
}

- (void)drawCandles
{
    objectToDraw = ObjectToDrawCandle;
    [self setNeedsDisplay];
}

- (void)drawLines
{
    objectToDraw = ObjectToDrawLine;
    [self setNeedsDisplay];
}

- (void)drawArea
{
    objectToDraw = ObjectToDrawArea;
    [self setNeedsDisplay];
}

- (void)drawChartsForArrayOfChartsNamesAndOptions:(NSArray *)charts
{
    [self.candlestickDrawer removeAllUpperStudies];
    for (NSDictionary *chart in charts) {
        if ([[chart objectForKey:@"name"] isEqualToString:NSLocalizedString(@"Simple Moving Average (MA)", nil)]) {
            [self.candlestickDrawer addUpperStudyToDraw:CDUpperChartTypeSimpleMovingAverage 
                                            withOptions:[chart objectForKey:@"options"]];
            
        } else if ([[chart objectForKey:@"name"] isEqualToString:NSLocalizedString(@"Exponential Moving Average (EMA)", nil)]) {
            [self.candlestickDrawer addUpperStudyToDraw:CDUpperChartTypeExponentalMovingAverage
                                            withOptions:[chart objectForKey:@"options"]];
            
        } else if ([[chart objectForKey:@"name"] isEqualToString:NSLocalizedString(@"Bollinger Bands", nil)]) {
            [self.candlestickDrawer addUpperStudyToDraw:CDUpperChartTypeBollingerBands
                                            withOptions:[chart objectForKey:@"options"]];
        }
    }
}

- (void)setLowerStudyTo:(NSString *)lowerStudyName withOptions:(NSDictionary *)options
{
    [self.candlestickDrawer removeLowerStudy];
    if ([lowerStudyName isEqualToString:NSLocalizedString(@"MACD", nil)]) {
        [self.candlestickDrawer setLowerStudyToDraw:CDLowerChartTypeMACD withOptions:options];
        
    } else if ([lowerStudyName isEqualToString:NSLocalizedString(@"RSI", nil)]) {
        [self.candlestickDrawer setLowerStudyToDraw:CDLowerChartTypeRSI withOptions:options];
        
    } else if ([lowerStudyName isEqualToString:NSLocalizedString(@"Stochastics", nil)]) {
        [self.candlestickDrawer setLowerStudyToDraw:CDLowerChartTypeRSIStochastics withOptions:options];
        
    }
}

- (void)drawRect:(CGRect)rect
{
    if (objectToDraw == ObjectToDrawBar) {
        [self.candlestickDrawer drawBarStockInRangeFrom:self.rangeToDraw];
    } else if (objectToDraw == ObjectToDrawCandle) {
        [self.candlestickDrawer drawCandlesticksInRangeFrom:self.rangeToDraw];
    } else if (objectToDraw == ObjectToDrawLine) {
        [self.candlestickDrawer drawLinesInRangeFrom:self.rangeToDraw];
    } else if (objectToDraw == ObjectToDrawArea) {
        [self.candlestickDrawer drawAreaInRangeFrom:self.rangeToDraw];
    }
}



@end
