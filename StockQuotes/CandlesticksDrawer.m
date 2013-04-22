//
//  CandlesticksDrawer.m
//  Plot
//
//  Created by Edward Khorkov on 10/6/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "CandlesticksDrawer.h"
#import "PlotDrawer.h"
#import "SMACalculator.h"
#import "EMACalculator.h"
#import "BollingerBandCalculator.h"
#import "AveragingType.h"
#import "MACDCalculator.h"
#import "RSICalculator.h"
#import "StochasticOscillator.h"

#define PERCENT_FOR_INDENT 0.05
#define INDENTATION_FROM_THE_EDGE_PERCENT 0.10
#define SIZE_OF_LOWER_BORDER 0
#define HEIGHT_OF_DATE_RECTANGLE 15
#define HEIGHT_OF_LOWER_STUDY 51

typedef enum
{
    Candlestick,
    BarStock,
    Line,
    Area
} PlotDrawerObject;

@interface CandlesticksDrawer()
{
    NSMutableArray *arrayOfCharts;
    NSMutableDictionary *lowerStudy;
    NSMutableArray *arrayOfChartLabels;
}
@property (nonatomic, strong) NSMutableArray *arrayOfCharts;
@property (nonatomic, strong) NSMutableDictionary *lowerStudy;
@property (nonatomic, strong) NSMutableArray *arrayOfChartLabels;

- (UIColor *)colorWithDictionary:(NSDictionary *)dictionary;
- (float)scaledValueForValue:(float)value withScale:(float)scale min:(float)min heightOfRectangle:(float)height;
- (void)setupMACDWithOptions:(NSDictionary *)options;
- (void)setupRSIWithOptions:(NSDictionary *)options;
- (void)setupStochasticsWithOptions:(NSDictionary *)options;
@end

@implementation CandlesticksDrawer

@synthesize candlesticks;

@synthesize scaleColor;
@synthesize closeIsHigherThanOpenColor;
@synthesize openIsHigherThanCloseColor;
@synthesize barsToRight;

@synthesize arrayOfCharts;
@synthesize lowerStudy;
@synthesize arrayOfChartLabels;

- (float)widthOccupiedByCandle
{
    return widthOfCandlestick+1;
}

- (NSMutableArray *)arrayOfChartLabels
{
    if (! arrayOfChartLabels) {
        arrayOfChartLabels = [[NSMutableArray alloc] init];
    }
    return arrayOfChartLabels;
}

- (void)setBarsToRight:(NSUInteger)bToRight
{
    barsToRight = bToRight;
    
    float widthToDrawIn = rectangleToDrawIn.size.width * (1-INDENTATION_FROM_THE_EDGE_PERCENT);
    widthOfCandlestick = widthToDrawIn/(numberOfCandlesticksOnScreen + self.barsToRight) - 1;
}

- (UIColor *)scaleColor
{
    if (!scaleColor) {
        // default color
        scaleColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1];
    }
    return scaleColor;
}

- (UIColor *)closeIsHigherThanOpenColor
{
    if (!closeIsHigherThanOpenColor) {
        // default color
        closeIsHigherThanOpenColor = [[UIColor alloc] initWithRed:0 green:1 blue:0 alpha:1];
    }
    return closeIsHigherThanOpenColor;
}

- (UIColor *)openIsHigherThanCloseColor
{
    if (!openIsHigherThanCloseColor) {
        //default color
        openIsHigherThanCloseColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:1];
    }
    return openIsHigherThanCloseColor;
}

- (id)initWithRectangleToDrawIn:(CGRect)rectangle numberOfCandlesticksOnScreen:(NSInteger)number
{
    if (self = [super init]) {
        self.barsToRight = 0;
        
        rectangleToDrawIn = rectangle;
        numberOfCandlesticksOnScreen = number;
        float widthToDrawIn = rectangleToDrawIn.size.width * (1-INDENTATION_FROM_THE_EDGE_PERCENT);
        widthOfCandlestick = widthToDrawIn/number - 1;
    }
    return self;
}

- (id)init
{
    return nil;
}

- (float)minimumOfCandlestickInRange:(NSRange)range
{
    float min = INFINITY;
    int counter = 0;
    for (int i = range.location; (i < range.length + range.location) && 
                                 (i < [self.candlesticks count]) && 
                                 (counter < numberOfCandlesticksOnScreen); i++, counter++) {
        NSDictionary *cstick = [self.candlesticks objectAtIndex:i];
        float currentMin = [[cstick objectForKey:@"min"] floatValue];
        float currentOpen = [[cstick objectForKey:@"open"] floatValue];
        float currentClose = [[cstick objectForKey:@"close"] floatValue];
        if (currentMin < min) {
            min = currentMin;
        }
        if (currentOpen < min) {
            min = currentOpen;
        }
        if (currentClose < min) {
            min = currentClose;
        }
        for (NSDictionary *chartDict in self.arrayOfCharts) {
            float chartValue = [[[chartDict objectForKey:@"arrayOfY"] objectAtIndex:i] floatValue];
            if (chartValue < min) {
                min = chartValue;
            }
        }
    }
    
    return min;
}

- (float)maximumOfCandlestickInRange:(NSRange)range
{
    float max = -INFINITY;
    int counter = 0;
    for (int i = range.location; (i < range.length + range.location) && 
                                 (i < [self.candlesticks count]) && 
                                 (counter < numberOfCandlesticksOnScreen); i++, counter++) {
        NSDictionary *cstick = [self.candlesticks objectAtIndex:i];
        float currentMax = [[cstick objectForKey:@"max"] floatValue];
        float currentOpen = [[cstick objectForKey:@"open"] floatValue];
        float currentClose = [[cstick objectForKey:@"close"] floatValue];
        
        if (currentMax > max) {
            max = currentMax;
        }
        if (currentOpen > max) {
            max = currentOpen;
        }
        if (currentClose > max) {
            max = currentClose;
        }
        
        for (NSDictionary *chartDict in self.arrayOfCharts) {
            float chartValue = [[[chartDict objectForKey:@"arrayOfY"] objectAtIndex:i] floatValue];
            if (chartValue > max) {
                max = chartValue;
            }
        }
    }
    return max;
}

- (void)drawPlotDrawerObject:(PlotDrawerObject)object InRange:(NSRange)range
{
    if (!self.candlesticks) return;
    
    int location = range.location;
    if (location >= [self.candlesticks count] - range.length) {
        range.location = [self.candlesticks count] - range.length - 1;
    }
    if (location < 0) {
        range.location = 0;
    }
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    float min = [self minimumOfCandlestickInRange:range];
    float max = [self maximumOfCandlestickInRange:range];
    float plusMinus = (max-min)*PERCENT_FOR_INDENT;
    min -=plusMinus;
    max +=plusMinus;
    
    float heightOfUpperPlot = rectangleToDrawIn.size.height - HEIGHT_OF_DATE_RECTANGLE;
    if (self.lowerStudy) {
        heightOfUpperPlot -= HEIGHT_OF_LOWER_STUDY;
    }
    
    CGRect dateRectangle = CGRectMake(rectangleToDrawIn.origin.x, heightOfUpperPlot,
                                      rectangleToDrawIn.size.width, HEIGHT_OF_DATE_RECTANGLE);
    [PlotDrawer setColorTo:[UIColor darkGrayColor] inContext:context];
    [PlotDrawer drawRectangle:dateRectangle inContext:context];
    
    CGRect upperStudyRectangle = CGRectMake(rectangleToDrawIn.origin.x, rectangleToDrawIn.origin.y,
                                            rectangleToDrawIn.size.width, heightOfUpperPlot);
    
    [PlotDrawer setColorTo:self.scaleColor inContext:context];
    [PlotDrawer drawVerticalScaleWithLinesInRect:upperStudyRectangle
                                   withAlignment:AlignmentRight 
                                     inRangeFrom:min rangeTo:max
                             withHorizontalLines:YES
                      withPrecisionForTextLabels:0
                 withNumberOfHorizontalLinesFrom:5 linesTo:8 
                                       inContext:context];
    
    
    const float scale = (upperStudyRectangle.size.height - SIZE_OF_LOWER_BORDER) / (max-min);
    
    const float scaledIndentation = upperStudyRectangle.size.width * INDENTATION_FROM_THE_EDGE_PERCENT;
    float centerX = upperStudyRectangle.size.width - scaledIndentation - widthOfCandlestick/2 - ((widthOfCandlestick+1) * self.barsToRight) - 1;
    float lmin, lmax, open, close;
    int counter = 0;
    
    float lastCloseValue = NAN;
    for (int i = range.location; (i < range.length + range.location) && 
         (i < [self.candlesticks count]) && 
         (counter < numberOfCandlesticksOnScreen); i++, counter++) {
        lmin = [[[self.candlesticks objectAtIndex:i] objectForKey:@"min"] floatValue];
        lmax = [[[self.candlesticks objectAtIndex:i] objectForKey:@"max"] floatValue];
        open = [[[self.candlesticks objectAtIndex:i] objectForKey:@"open"] floatValue];
        close = [[[self.candlesticks objectAtIndex:i] objectForKey:@"close"] floatValue];
        
        if (close > open) {
            [PlotDrawer setColorTo:self.closeIsHigherThanOpenColor inContext:context];
        } else {
            [PlotDrawer setColorTo:self.openIsHigherThanCloseColor inContext:context];
        }
        
        lmin = [self scaledValueForValue:lmin withScale:scale min:min heightOfRectangle:upperStudyRectangle.size.height];
        lmax = [self scaledValueForValue:lmax withScale:scale min:min heightOfRectangle:upperStudyRectangle.size.height];
        open = [self scaledValueForValue:open withScale:scale min:min heightOfRectangle:upperStudyRectangle.size.height];
        close = [self scaledValueForValue:close withScale:scale min:min heightOfRectangle:upperStudyRectangle.size.height];
        
        if (object == Candlestick) {
            [PlotDrawer drawCandlestickInRect:upperStudyRectangle
                                      centerX:centerX
                            withMaxCoordinate:lmax minCoordinate:lmin
                               openCoordinate:open closeCoordinate:close
                                    withWidth:widthOfCandlestick
                                    inContext:context];
        } else if (object == BarStock) {
            [PlotDrawer drawBarStockInRect:upperStudyRectangle
                                      centerX:centerX
                            withMaxCoordinate:lmax minCoordinate:lmin
                               openCoordinate:open closeCoordinate:close
                                    withWidth:widthOfCandlestick
                                    inContext:context];
        } else if (object == Line) {
            if (! isnan(lastCloseValue) && ! isnan(close)) {
                [PlotDrawer drawLineFromX:centerX y:close
                                      toX:(centerX + widthOfCandlestick + 1) y:lastCloseValue
                                inContext:context];
            }
        } else if (object == Area) {
            if (! isnan(lastCloseValue) && ! isnan(close)) {
                [PlotDrawer setColorTo:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] inContext:context];
                
                CGFloat lastCenterX = centerX + widthOfCandlestick + 2;
                
                CGPoint points[4];
                points[0].x = lastCenterX;
                points[0].y = lastCloseValue;
                
                points[1].x = centerX;
                points[1].y = close;
                
                points[2].x = centerX;
                points[2].y = [self scaledValueForValue:min withScale:scale min:min heightOfRectangle:heightOfUpperPlot];
                
                points[3].x = lastCenterX;
                points[3].y = [self scaledValueForValue:min withScale:scale min:min heightOfRectangle:heightOfUpperPlot];
                
                [PlotDrawer drawPolyhedronForPoints:points count:4 inContext:context];
            }
        }
        lastCloseValue = close;
        
        const int numberOfDateOnScreen = 5;
        const int index = i;
        const int nDivN = numberOfCandlesticksOnScreen/numberOfDateOnScreen;
        if (nDivN) {
            if ((index % nDivN) == 0) {
                [PlotDrawer setColorTo:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] inContext:context];
                [PlotDrawer drawText:[[self.candlesticks objectAtIndex:index] objectForKey:@"date"]
               withCenterXCoordinate:centerX
                      topYCoordinate:dateRectangle.origin.y
                           inContext:context];
                [PlotDrawer drawRectangle:CGRectMake(centerX-1, dateRectangle.origin.y, 3, 3) 
                                inContext:context];
            }
        }
        
        centerX -= widthOfCandlestick + 1;
    }
    
    CGRect dateRectangleRightAppend = CGRectMake(rectangleToDrawIn.size.width * (1 - INDENTATION_FROM_THE_EDGE_PERCENT), heightOfUpperPlot,
                                                rectangleToDrawIn.size.width, HEIGHT_OF_DATE_RECTANGLE);
    [PlotDrawer setColorTo:[UIColor darkGrayColor] inContext:context];
    [PlotDrawer drawRectangle:dateRectangleRightAppend inContext:context];
    
    CGContextSetLineWidth(context, 1);
    
    for (NSDictionary *chartDict in self.arrayOfCharts) {
        [PlotDrawer setColorTo:[chartDict objectForKey:@"color"] inContext:context];

        if ([chartDict objectForKey:@"dash"]) {
            CGFloat dashes[] = { 5, 3};
            CGContextSetLineDash( context, 0.0, dashes, 2 );
        }
        
        NSArray *arrayOfY = [chartDict objectForKey:@"arrayOfY"];
        
        float x = upperStudyRectangle.size.width - scaledIndentation - widthOfCandlestick/2 - ((widthOfCandlestick+1) * self.barsToRight) - 1;
        int counter = 0;
        
        float y, scaledY, scaledYMinusOne = NAN;
        for (int i = range.location; (i < range.length + range.location) && 
                                     (i < [self.candlesticks count]) && 
                                     (counter < numberOfCandlesticksOnScreen); i++, counter++) {
            
            y = [[arrayOfY objectAtIndex:i] floatValue];
            if (! isnan(y)) {
                scaledY = (y - min)*scale;
                scaledY = (upperStudyRectangle.size.height - SIZE_OF_LOWER_BORDER) - scaledY;
                
                if (! isnan(scaledYMinusOne)) {
                    [PlotDrawer drawLineFromX:x y:scaledY 
                                          toX:(x + widthOfCandlestick + 1) y:scaledYMinusOne
                                    inContext:context];
                }
                
                scaledYMinusOne = scaledY;
            }
            x -= widthOfCandlestick + 1;
        }
        
        if ([chartDict objectForKey:@"dash"]) {
            CGFloat dashes[] = { 5, 3};
            CGContextSetLineDash( context, 0.0, dashes, 0 );
        }
    }
    
    if (self.lowerStudy) {
        CGRect lowerStudyRectangle = CGRectMake(rectangleToDrawIn.origin.x, heightOfUpperPlot + HEIGHT_OF_DATE_RECTANGLE + 1,
                                                rectangleToDrawIn.size.width, HEIGHT_OF_LOWER_STUDY);
        
        NSDictionary *histogram = [self.lowerStudy objectForKey:@"histogram"];
        NSArray *charts = [self.lowerStudy objectForKey:@"arrayOfCharts"];
        NSArray *horizontalLines = [self.lowerStudy objectForKey:@"arrayOfHorizontalLines"];
        
        float lowerMin = MAXFLOAT;
        float lowerMax = -MAXFLOAT;
        int counter = 0;
        for (int i = range.location; (i < range.length + range.location) && 
                                     (i < [self.candlesticks count]) && 
                                     (counter < numberOfCandlesticksOnScreen); i++, counter++) {
            if (histogram) {
                float histogramValue = [[[[self.lowerStudy objectForKey:@"histogram"] objectForKey:@"arrayOfY"] objectAtIndex:i] floatValue];
                if (lowerMax < histogramValue) {
                    lowerMax = histogramValue;
                }
                if (lowerMin > histogramValue) {
                    lowerMin = histogramValue;
                }
            }
            
            if (horizontalLines) {
                for (NSDictionary *line in horizontalLines) {
                    float yCoordinate = [[line objectForKey:@"yCoordinate"] floatValue];
                    
                    if (lowerMax < yCoordinate) {
                        lowerMax = yCoordinate;
                    }
                    if (lowerMin > yCoordinate) {
                        lowerMin = yCoordinate;
                    }
                }
            }
            
            for (NSDictionary *chart in charts) {
                float value = [[[chart objectForKey:@"arrayOfY"] objectAtIndex:i] floatValue];
                if (lowerMax < value) {
                    lowerMax = value;
                }
                if (lowerMin > value) {
                    lowerMin = value;
                }
            }
            
            
        }
        float plusMinus = (lowerMax-lowerMin)*PERCENT_FOR_INDENT;
        if (!plusMinus) {
            plusMinus = 1;
        }
        lowerMin -=plusMinus;
        lowerMax +=plusMinus;
        
        if ([self.lowerStudy objectForKey:@"rangeToDrawMax"]) {
            lowerMax = [[self.lowerStudy objectForKey:@"rangeToDrawMax"] floatValue];
        }
        if ([self.lowerStudy objectForKey:@"rangeToDrawMin"]) {
            lowerMin = [[self.lowerStudy objectForKey:@"rangeToDrawMin"] floatValue];
        }
        
        const float lowerScale = (lowerStudyRectangle.size.height - SIZE_OF_LOWER_BORDER) / (lowerMax-lowerMin);
        
        [PlotDrawer setColorTo:self.scaleColor inContext:context];
        [PlotDrawer drawVerticalScaleWithLinesInRect:lowerStudyRectangle
                                       withAlignment:AlignmentRight 
                                         inRangeFrom:lowerMin rangeTo:lowerMax
                                 withHorizontalLines:! horizontalLines
                          withPrecisionForTextLabels:1
                     withNumberOfHorizontalLinesFrom:3 linesTo:3
                                           inContext:context];
        
        if (horizontalLines) {
            UIGraphicsPushContext(context);
            CGContextSetLineWidth(context, 1);
            
            for (NSDictionary *line in horizontalLines) {
                [PlotDrawer setColorTo:[line objectForKey:@"color"] inContext:context];
                float yCoordinate = [[line objectForKey:@"yCoordinate"] floatValue];
                yCoordinate = [self scaledValueForValue:yCoordinate withScale:lowerScale min:lowerMin heightOfRectangle:HEIGHT_OF_LOWER_STUDY];
                yCoordinate += lowerStudyRectangle.origin.y;

                [PlotDrawer drawLineFromX:lowerStudyRectangle.origin.x y:yCoordinate
                                      toX:lowerStudyRectangle.size.width * (1-INDENTATION_FROM_THE_EDGE_PERCENT) y:yCoordinate
                                inContext:context];
                
                if ([line objectForKey:@"label"]) {
                    NSString *label = [line objectForKey:@"label"];
                    CGFloat labelYCoorditate = yCoordinate - 8;
                    if (labelYCoorditate < lowerStudyRectangle.origin.y) {
                        labelYCoorditate = lowerStudyRectangle.origin.y;
                    }
                    CGFloat heigthOfLabel = [label sizeWithFont:[UIFont systemFontOfSize:12]].height;
                    if ((labelYCoorditate + heigthOfLabel) > lowerStudyRectangle.origin.y + lowerStudyRectangle.size.height) {
                        labelYCoorditate = lowerStudyRectangle.origin.y + lowerStudyRectangle.size.height - heigthOfLabel;
                    }
                    
                    [PlotDrawer drawText:label
                      withTopXCooridnate:lowerStudyRectangle.size.width * (1-INDENTATION_FROM_THE_EDGE_PERCENT) + 4
                          topYCoordinate:labelYCoorditate
                               inContext:context];
                }
            }
            
            UIGraphicsPopContext();
        }

        if (histogram) {
            [PlotDrawer setColorTo:[histogram objectForKey:@"color"] inContext:context];
            
            float x = lowerStudyRectangle.size.width - scaledIndentation - widthOfCandlestick/2 - ((widthOfCandlestick+1) * self.barsToRight) - 1;
            int counter = 0;
            
            float zeroCoordinate = [self scaledValueForValue:0 withScale:lowerScale min:lowerMin heightOfRectangle:HEIGHT_OF_LOWER_STUDY];
            zeroCoordinate += lowerStudyRectangle.origin.y;
            
            for (int i = range.location; (i < range.length + range.location) && 
                                         (i < [self.candlesticks count]) && 
                                         (counter < numberOfCandlesticksOnScreen); i++, counter++) {
                float yCoordinate = [[[histogram objectForKey:@"arrayOfY"] objectAtIndex:i] floatValue];
                if (! isnan(yCoordinate)) {
                    yCoordinate = [self scaledValueForValue:yCoordinate withScale:lowerScale min:lowerMin heightOfRectangle:HEIGHT_OF_LOWER_STUDY];
                    yCoordinate += lowerStudyRectangle.origin.y;
                    
                    CGRect rect = CGRectMake(x - widthOfCandlestick/2, zeroCoordinate, widthOfCandlestick, yCoordinate - zeroCoordinate);
                    [PlotDrawer drawRectangle:rect inContext:context];
                }
                
                x -= widthOfCandlestick + 1;
            }
        }
        
        if (charts) {
            CGContextSetLineWidth(context, 1);
            for (NSDictionary *chart in charts) {
                [PlotDrawer setColorTo:[chart objectForKey:@"color"] inContext:context];
                
                if ([chart objectForKey:@"dash"]) {
                    CGFloat dashes[] = { 5, 3};
                    CGContextSetLineDash( context, 0.0, dashes, 2 );
                }
                
                NSArray *arrayOfY = [chart objectForKey:@"arrayOfY"];
                
                float x = lowerStudyRectangle.size.width - scaledIndentation - widthOfCandlestick/2 - ((widthOfCandlestick+1) * self.barsToRight) - 1;
                int counter = 0;
                
                float y, scaledY, scaledYMinusOne = NAN;
                for (int i = range.location; (i < range.length + range.location) && 
                                             (i < [self.candlesticks count]) && 
                                             (counter < numberOfCandlesticksOnScreen); i++, counter++) {
                    
                    y = [[arrayOfY objectAtIndex:i] floatValue];
                    if (! isnan(y)) {
                        scaledY = [self scaledValueForValue:y withScale:lowerScale min:lowerMin heightOfRectangle:lowerStudyRectangle.size.height];
                        
                        if (! isnan(scaledYMinusOne)) {
                            [PlotDrawer drawLineFromX:x y:scaledY + lowerStudyRectangle.origin.y 
                                                  toX:(x + widthOfCandlestick + 1) y:scaledYMinusOne
                                            inContext:context];
                        }
                        
                        scaledYMinusOne = scaledY + lowerStudyRectangle.origin.y;
                    }
                    x -= widthOfCandlestick + 1;
                }
                
                if ([chart objectForKey:@"dash"]) {
                    CGFloat dashes[] = { 5, 3};
                    CGContextSetLineDash( context, 0.0, dashes, 0 );
                }
            }
        }
    }
    
    CGPoint pointToDrawText;
    pointToDrawText.x = 3;
    pointToDrawText.y = 3;
    for (NSDictionary *chartLabel in self.arrayOfChartLabels) {
        NSString *shortName = [chartLabel objectForKey:@"shortName"];
        
        [PlotDrawer setColorTo:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] inContext:context];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize sizeOfFont = [shortName sizeWithFont:font];
        CGRect rectToDraw = CGRectMake(pointToDrawText.x, pointToDrawText.y,
                                       sizeOfFont.width, sizeOfFont.height);
        
        [PlotDrawer drawRectangle:rectToDraw inContext:context];
        
        
        [PlotDrawer setColorTo:[chartLabel objectForKey:@"color"] inContext:context];
        
        CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 3.0f, [[UIColor blackColor] CGColor]);
        
        [PlotDrawer drawText:shortName
          withTopXCooridnate:pointToDrawText.x  
              topYCoordinate:pointToDrawText.y
                   inContext:context];
        
        pointToDrawText.y += 15;
    }
}

- (void)drawCandlesticksInRangeFrom:(NSRange)range
{
    [self drawPlotDrawerObject:Candlestick InRange:range];
}

- (void)drawBarStockInRangeFrom:(NSRange)range
{
    [self drawPlotDrawerObject:BarStock InRange:range];
}

- (void)drawLinesInRangeFrom:(NSRange)range
{
    [self drawPlotDrawerObject:Line InRange:range];
}

- (void)drawAreaInRangeFrom:(NSRange)range
{
    [self drawPlotDrawerObject:Area InRange:range];
}

- (void)addUpperStudyToDraw:(CDUpperChartType)chartType withOptions:(NSDictionary *)options
{
    if (!arrayOfCharts) {
        arrayOfCharts = [[NSMutableArray alloc] init];
    }
    
    id <IndicatorCalcProtocol> calculator;
    UIColor *color = [self colorWithDictionary:[[options objectForKey:@"color"] objectForKey:@"color"]];
    
    if (chartType == CDUpperChartTypeSimpleMovingAverage) {
        calculator = [[SMACalculator alloc] initWithAveragingIntervalLength:[[options objectForKey:@"length"] integerValue]];
    } else if (chartType == CDUpperChartTypeExponentalMovingAverage) {
        calculator = [[EMACalculator alloc] initWithAveragingIntervalLength:[[options objectForKey:@"length"] integerValue]];
    } else if (chartType == CDUpperChartTypeBollingerBands) {
        calculator = [[BollingerBandCalculator alloc] initWithSMALength:[[options objectForKey:@"length"] integerValue]
                                                        upDeviationMult:[[options objectForKey:@"numDevUp"] floatValue]
                                                      downDeviationMult:[[options objectForKey:@"numDevDn"] floatValue]];
    }
    
    NSArray *arrayOfY = [calculator calculateForDataArray:self.candlesticks 
                                            forValueNamed:[options objectForKey:@"price"]
                                                  ordered:FROM_LATE_TO_EARLY];
    
    if (calculator) {
        if ((chartType == CDUpperChartTypeSimpleMovingAverage) || (chartType == CDUpperChartTypeExponentalMovingAverage)) {
            NSMutableDictionary *chartDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              arrayOfY, @"arrayOfY",
                                              color, @"color",
                                              nil];
            [self.arrayOfCharts addObject:chartDict];
        }
        if (chartType == CDUpperChartTypeBollingerBands) {
            NSMutableArray *lowerbandArray = [NSMutableArray array];
            NSMutableArray *smaArray = [NSMutableArray array];
            NSMutableArray *upperbandArray = [NSMutableArray array];
            
            for (NSDictionary *dict in arrayOfY) {
                [lowerbandArray addObject:[dict objectForKey:@"lowerband"]];
                [smaArray addObject:[dict objectForKey:@"sma"]];
                [upperbandArray addObject:[dict objectForKey:@"upperband"]];
            }
            NSDictionary *lowerbandDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           lowerbandArray, @"arrayOfY",
                                           color, @"color",
                                           nil];
            NSDictionary *smaDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     smaArray, @"arrayOfY",
                                     color, @"color",
                                     @"dash", @"dash",
                                     nil];
            NSDictionary *upperbandDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                           upperbandArray, @"arrayOfY",
                                           color, @"color",
                                           nil];
            [self.arrayOfCharts addObject:lowerbandDict];
            [self.arrayOfCharts addObject:smaDict];
            [self.arrayOfCharts addObject:upperbandDict];
        }
        
    }
    
    [self.arrayOfChartLabels addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"upperStudy",
                                        color, @"color",
                                        [options objectForKey:@"shortName"], @"shortName",
                                        nil]];
}

- (void)removeAllUpperStudies
{
    if (self.arrayOfCharts) {
        self.arrayOfCharts = nil;
    }
    
    NSMutableArray *dictsToRemove = [NSMutableArray array];
    
    for (NSDictionary *dict in self.arrayOfChartLabels) {
        if ([dict objectForKey:@"upperStudy"]) {
            [dictsToRemove addObject:dict];
        }
    }
    
    for (NSDictionary *dict in dictsToRemove) {
        [self.arrayOfChartLabels removeObject:dict];
    }
}



- (void)setLowerStudyToDraw:(CDLowerChartType)chartType withOptions:(NSDictionary *)options
{
    if (chartType == CDLowerChartTypeMACD) {
        [self setupMACDWithOptions:options];
    } else if (chartType == CDLowerChartTypeRSI) {
        [self setupRSIWithOptions:options];
    } else if (chartType == CDLowerChartTypeRSIStochastics) {
        [self setupStochasticsWithOptions:options];
    }
}

- (void)removeLowerStudy
{
    self.lowerStudy = nil;
    NSMutableArray *dictsToRemove = [NSMutableArray array];
    
    for (NSDictionary *dict in self.arrayOfChartLabels) {
        if ([dict objectForKey:@"lowerStudy"]) {
            [dictsToRemove addObject:dict];
        }
    }
    
    for (NSDictionary *dict in dictsToRemove) {
        [self.arrayOfChartLabels removeObject:dict];
    }
}

- (UIColor *)colorWithDictionary:(NSDictionary *)dictionary
{
    UIColor *color = [UIColor colorWithRed:[[dictionary objectForKey:@"red"] floatValue]
                                     green:[[dictionary objectForKey:@"green"] floatValue]
                                      blue:[[dictionary objectForKey:@"blue"] floatValue]
                                     alpha:[[dictionary objectForKey:@"alpha"] floatValue]];
    return color;
}

- (float)scaledValueForValue:(float)value withScale:(float)scale min:(float)min heightOfRectangle:(float)height
{
    value -= min;
    value *= scale;
    value = height - value;
    return value;
}

- (void)setupMACDWithOptions:(NSDictionary *)options
{
    enum AveragingType type = EMA;
    if ([[options objectForKey:@"averageType"] isEqualToString:@"sma"]) {
        type = SMA;
    }
    
    MACDCalculator *calculator = [[MACDCalculator alloc] initWithMACDLength:[[options objectForKey:@"MACDLength"] integerValue]
                                                                 fastLength:[[options objectForKey:@"fastLength"] integerValue]
                                                                 slowLength:[[options objectForKey:@"slowLength"] integerValue]
                                                              averagingType:type];
    NSArray *array = [calculator calculateForDataArray:self.candlesticks
                                         forValueNamed:@"close"
                                               ordered:FROM_LATE_TO_EARLY];
    
    NSMutableArray *arrayOfMacd = [NSMutableArray array];
    NSMutableArray *arrayOfSignal = [NSMutableArray array];
    NSMutableArray *arrayOfHistogram = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [arrayOfMacd addObject:[dict objectForKey:@"macd"]];
        [arrayOfSignal addObject:[dict objectForKey:@"signal"]];
        [arrayOfHistogram addObject:[dict objectForKey:@"histogram"]];
    }
    
    NSDictionary *macdColorDict = [[options objectForKey:@"color"] objectForKey:@"macdColor"];
    NSDictionary *signalColorDict = [[options objectForKey:@"color"] objectForKey:@"signalLineColor"];
    NSDictionary *histogramColorDict = [[options objectForKey:@"color"] objectForKey:@"histogramColor"];
    
    NSDictionary *dictOfMacd = [NSDictionary dictionaryWithObjectsAndKeys:
                                arrayOfMacd, @"arrayOfY",
                                [self colorWithDictionary:macdColorDict], @"color",
                                nil];
    NSDictionary *dictOfSignal = [NSDictionary dictionaryWithObjectsAndKeys:
                                  arrayOfSignal, @"arrayOfY",
                                  [self colorWithDictionary:signalColorDict], @"color",
                                  nil];
    NSArray *arrOfCharts = [NSArray arrayWithObjects:dictOfMacd, dictOfSignal, nil];
    
    NSDictionary *histogram = [NSDictionary dictionaryWithObjectsAndKeys:
                               arrayOfHistogram, @"arrayOfY",
                               [self colorWithDictionary:histogramColorDict], @"color",
                               nil];
    
    self.lowerStudy = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                       arrOfCharts, @"arrayOfCharts",
                       histogram, @"histogram",
                       nil];
    
    [self.arrayOfChartLabels addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"lowerStudy",
                                        [self colorWithDictionary:macdColorDict], @"color",
                                        [options objectForKey:@"shortName"], @"shortName",
                                        nil]];
}

- (void)setupRSIWithOptions:(NSDictionary *)options
{
    RSICalculator *calculator = [[RSICalculator alloc] initWithAveragingIntervalLength:[[options objectForKey:@"length"] floatValue]];
    
    NSArray *arrayOfY = [calculator calculateForDataArray:self.candlesticks 
                                            forValueNamed:[options objectForKey:@"price"] 
                                                  ordered:FROM_LATE_TO_EARLY];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          arrayOfY, @"arrayOfY",
                          [self colorWithDictionary:[[options objectForKey:@"color"] objectForKey:@"color"]], @"color",
                          nil];
    
    self.lowerStudy = [NSMutableDictionary dictionary];
    
    [self.lowerStudy setObject:[NSArray arrayWithObject:dict]
                        forKey:@"arrayOfCharts"];
    
    float overBoughtValue = [[options objectForKey:@"overBought"] floatValue];
    NSDictionary *overBought = [NSDictionary dictionaryWithObjectsAndKeys:
                                [options objectForKey:@"overBought"], @"yCoordinate",
                                [NSString stringWithFormat:@"%g", overBoughtValue], @"label",
                                [UIColor colorWithRed:.67 green:.67 blue:.67 alpha:1], @"color",
                                nil];
    
    float overSoldValue = [[options objectForKey:@"overSold"] floatValue];
    NSDictionary *overSold = [NSDictionary dictionaryWithObjectsAndKeys:
                              [options objectForKey:@"overSold"], @"yCoordinate",
                              [NSString stringWithFormat:@"%g", overSoldValue], @"label",
                              [UIColor colorWithRed:.67 green:.67 blue:.67 alpha:1], @"color",
                              nil];
    
    [self.lowerStudy setObject:[NSArray arrayWithObjects:overBought, overSold, nil]
                        forKey:@"arrayOfHorizontalLines"];
    
    [self.lowerStudy setObject:@"100" forKey:@"rangeToDrawMax"];
    [self.lowerStudy setObject:@"0" forKey:@"rangeToDrawMin"];
    
    
    [self.arrayOfChartLabels addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"lowerStudy",
                                        [self colorWithDictionary:[[options objectForKey:@"color"] objectForKey:@"color"]], @"color",
                                        [options objectForKey:@"shortName"], @"shortName",
                                        nil]];
    
}

- (void)setupStochasticsWithOptions:(NSDictionary *)options
{
    enum AveragingType type = SMA;
    if ([[options objectForKey:@"smoothingType"] isEqualToString:@"ema"]) {
        type = EMA;
    }
    
    StochasticOscillator *oscillator = [[StochasticOscillator alloc] initWithLookBackPeriod:[[options objectForKey:@"KPeriod"] floatValue]
                                                                       firstSmoothingPeriod:[[options objectForKey:@"slowingPeriod"] floatValue]
                                                                      secondSmoothingPeriod:[[options objectForKey:@"DPeriod"] floatValue]
                                                                              averagingType:type];
    NSArray *arrayOfY = [oscillator calculateForDataArray:self.candlesticks
                                        forHighValueNamed:[options objectForKey:@"priceH"]
                                        currentValueNamed:[options objectForKey:@"priceC"]
                                            lowValueNamed:[options objectForKey:@"priceL"]
                                                  ordered:FROM_LATE_TO_EARLY];
    
    NSMutableArray *fullDArray = [NSMutableArray array];
    NSMutableArray *fullKArray = [NSMutableArray array];
    
    for (NSDictionary *dict in arrayOfY) {
        if ([[dict objectForKey:@"d_correctness"] isEqualToString:@"yes"]) {
            [fullDArray addObject:[dict objectForKey:@"full_d"]];
        } else {
            [fullDArray addObject:[NSNumber numberWithFloat:NAN]];
        }
        
        if ([[dict objectForKey:@"k_correctness"] isEqualToString:@"yes"]) {
            [fullKArray addObject:[dict objectForKey:@"full_k"]];
        } else {
            [fullKArray addObject:[NSNumber numberWithFloat:NAN]];
        }
    }
    
    NSDictionary *fullDDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               fullDArray, @"arrayOfY",
                               [self colorWithDictionary:[[options objectForKey:@"color"] objectForKey:@"fullDColor"]], @"color",
                               nil];
    NSDictionary *fullKDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               fullKArray, @"arrayOfY",
                               [self colorWithDictionary:[[options objectForKey:@"color"] objectForKey:@"fullKColor"]], @"color",
                               nil];
    
    self.lowerStudy = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObjects:fullDDict, fullKDict, nil]
                                                         forKey:@"arrayOfCharts"];
    
    float overBoughtValue = [[options objectForKey:@"overBought"] floatValue];
    NSDictionary *overBought = [NSDictionary dictionaryWithObjectsAndKeys:
                                [options objectForKey:@"overBought"], @"yCoordinate",
                                [NSString stringWithFormat:@"%g", overBoughtValue], @"label",
                                [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1], @"color",
                                nil];
    
    float overSoldValue = [[options objectForKey:@"overSold"] floatValue];
    NSDictionary *overSold = [NSDictionary dictionaryWithObjectsAndKeys:
                              [options objectForKey:@"overSold"], @"yCoordinate",
                              [NSString stringWithFormat:@"%g", overSoldValue], @"label",
                              [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1], @"color",
                              nil];
    
    [self.lowerStudy setObject:[NSArray arrayWithObjects:overBought, overSold, nil]
                        forKey:@"arrayOfHorizontalLines"];
    
    [self.arrayOfChartLabels addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"lowerStudy",
                                        [self colorWithDictionary:[[options objectForKey:@"color"] objectForKey:@"fullDColor"]], @"color",
                                        [options objectForKey:@"shortName"], @"shortName",
                                        nil]];
}


@end
