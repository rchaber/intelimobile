//
//  PlotView.h
//  Plot
//
//  Created by Edward Khorkov on 10/6/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CandlesticksDrawer.h"

@interface PlotDrawingView : UIView
{
    CandlesticksDrawer *candlestickDrawer;
    NSRange rangeToDraw;
    NSUInteger barsToRight;
}

@property (nonatomic, strong) CandlesticksDrawer *candlestickDrawer;
@property (nonatomic, assign) NSRange rangeToDraw;
@property (nonatomic, assign) NSUInteger barsToRight;

- (void)drawBars;
- (void)drawCandles;
- (void)drawLines;
- (void)drawArea;

- (void)setCandlesticks:(NSMutableArray *)cs;

// array with names of charts
- (void)drawChartsForArrayOfChartsNamesAndOptions:(NSArray *)charts;

- (void)setLowerStudyTo:(NSString *)lowerStudyName withOptions:(NSDictionary *)options;

@end
