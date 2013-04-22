//
//  PlotDrawer.h
//  Plot
//
//  Created by Edward Khorkov on 10/6/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    AlignmentLeft,
    AlignmentRight
} Alignment;

@interface PlotDrawer : NSObject

+ (void)drawVerticalScaleWithLinesInRect:(CGRect)bounds 
                           withAlignment:(Alignment)alignment 
                             inRangeFrom:(float)minRange rangeTo:(float)maxRange 
                     withHorizontalLines:(BOOL)drawWithHorizontalLines
              withPrecisionForTextLabels:(NSUInteger)precision
         withNumberOfHorizontalLinesFrom:(NSInteger)minLines linesTo:(NSInteger)maxLines 
                               inContext:(CGContextRef)context;

+ (void)drawText:(NSString *)text withCenterXCoordinate:(float)centerX
                                         topYCoordinate:(float)topY
                                              inContext:(CGContextRef)context;

+ (void)drawText:(NSString *)text withTopXCooridnate:(float)topX
                                      topYCoordinate:(float)topY
                                           inContext:(CGContextRef)context;

+ (void)drawCandlestickInRect:(CGRect)bounds 
                      centerX:(float)center
            withMaxCoordinate:(float)maxCoord minCoordinate:(float)minCoord 
               openCoordinate:(float)openCoord closeCoordinate:(float)closeCoord withWidth:(float)width 
                    inContext:(CGContextRef)context;

+ (void)drawBarStockInRect:(CGRect)bounds
                   centerX:(float)center
         withMaxCoordinate:(float)maxCoord minCoordinate:(float)minCoord 
            openCoordinate:(float)openCoord closeCoordinate:(float)closeCoord withWidth:(float)width 
                 inContext:(CGContextRef)context;

+ (void)drawLineFromX:(float)x1 y:(float)y1 
                  toX:(float)x2 y:(float)y2
            inContext:(CGContextRef)context;

+ (void)drawRectangle:(CGRect)bounds
            inContext:(CGContextRef)context;

// last point is connected to first
+ (void)drawPolyhedronForPoints:(CGPoint *)points
                          count:(size_t)count
                      inContext:(CGContextRef)context;

+ (void)setColorTo:(UIColor *)color
         inContext:(CGContextRef)context;

@end
