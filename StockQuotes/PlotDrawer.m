//
//  PlotDrawer.m
//  Plot
//
//  Created by Edward Khorkov on 10/6/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "PlotDrawer.h"

@implementation PlotDrawer

#define INDENTATION_FROM_THE_EDGE_PERCENT 0.10 
#define SIZE_OF_LOWER_BORDER 0
#define HASH_MARK_FONT_SIZE 12.0
#define WIDTH_OF_VERTICAL_LINE 1
#define WIDTH_OF_GORIZONTAL_LINE 1

+ (void)drawVerticalScaleWithLinesInRect:(CGRect)bounds 
                           withAlignment:(Alignment)alignment 
                             inRangeFrom:(float)minRange rangeTo:(float)maxRange 
                     withHorizontalLines:(BOOL)drawWithHorizontalLines
              withPrecisionForTextLabels:(NSUInteger)precision
         withNumberOfHorizontalLinesFrom:(NSInteger)minLines linesTo:(NSInteger)maxLines 
                               inContext:(CGContextRef)context
{
    if (minRange >= maxRange) return;
    
    if (minLines <= 0) return;
    if (minLines > maxLines) return;
    
    UIGraphicsPushContext(context);
    
    float rangeToFit = maxRange - minRange;
    NSInteger roundedRangeToFit = roundf(rangeToFit);
    
    NSInteger modulo = INT_MAX;
    NSInteger numberOfLines = -1;
    for (NSInteger i = minLines; i <= maxLines; i++) {
        NSInteger newModulo = roundedRangeToFit % (i+1);
        if (newModulo < modulo) {
            modulo = newModulo;
            numberOfLines = i;
        }
    }

    
    float scale = ((float)bounds.size.height - SIZE_OF_LOWER_BORDER) / rangeToFit;
    
    float step = (float)rangeToFit / (numberOfLines+1);
    float scaledStep = step*scale;
    float scaledLineCoordinates = bounds.origin.y + scaledStep;
    
    float scaledIndentation = bounds.size.width * INDENTATION_FROM_THE_EDGE_PERCENT;
    
    float xCoordinateForVerticalLine = 0;
    if (alignment == AlignmentLeft) {
        xCoordinateForVerticalLine = scaledIndentation;
    } else {
        xCoordinateForVerticalLine = bounds.size.width - scaledIndentation;
    }
    CGContextSetLineWidth(context, WIDTH_OF_VERTICAL_LINE);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xCoordinateForVerticalLine, bounds.origin.y);
    CGContextAddLineToPoint(context, xCoordinateForVerticalLine, bounds.origin.y + bounds.size.height);
    
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    UIFont *font = [UIFont systemFontOfSize:HASH_MARK_FONT_SIZE];
    CGContextStrokePath(context);
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, WIDTH_OF_GORIZONTAL_LINE);
    float textNumber = maxRange - step;
    NSString *text;
    if (drawWithHorizontalLines) {
        for (int i = 0; i < numberOfLines; i++) {
            if (alignment == AlignmentLeft) {
                CGContextMoveToPoint(context, scaledIndentation, scaledLineCoordinates);
                CGContextAddLineToPoint(context, bounds.size.width, scaledLineCoordinates);
                
                text = [NSString stringWithFormat:@"% .*f", precision, textNumber];
                CGRect rect;
                rect.size = [text sizeWithFont:font];
                rect.origin.x = scaledIndentation - rect.size.width - 1;
                rect.origin.y = scaledLineCoordinates - rect.size.height/2;
                [text drawInRect:rect withFont:font];
            } else {
                CGContextMoveToPoint(context, 0, scaledLineCoordinates);
                CGContextAddLineToPoint(context, bounds.size.width - scaledIndentation, scaledLineCoordinates);

                text = [NSString stringWithFormat:@"% .*f", precision, textNumber];
                CGRect rect;
                rect.size = [text sizeWithFont:font];
                rect.origin.x = bounds.size.width - scaledIndentation + 1;
                rect.origin.y = scaledLineCoordinates - rect.size.height/2;
                [text drawInRect:rect withFont:font];
            }
            
            scaledLineCoordinates += scaledStep;
            textNumber -= step;
        }               
    }

    
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

+ (void)drawText:(NSString *)text withCenterXCoordinate:(float)centerX topYCoordinate:(float)topY inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    UIFont *font = [UIFont systemFontOfSize:HASH_MARK_FONT_SIZE];
    CGSize textSize = [text sizeWithFont:font];
    CGRect rect = CGRectMake(centerX - textSize.width/2, topY, textSize.width, textSize.height);
    [text drawInRect:rect withFont:font];
    
    UIGraphicsPopContext();
}

+ (void)drawText:(NSString *)text withTopXCooridnate:(float)topX
                                      topYCoordinate:(float)topY
                                           inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    UIFont *font = [UIFont systemFontOfSize:HASH_MARK_FONT_SIZE];
    CGSize textSize = [text sizeWithFont:font];
    CGRect rect = CGRectMake(topX, topY, textSize.width, textSize.height);
    [text drawInRect:rect withFont:font];
    
    UIGraphicsPopContext();
}

+ (void)drawCandlestickInRect:(CGRect)bounds 
                      centerX:(float)center
            withMaxCoordinate:(float)maxCoord minCoordinate:(float)minCoord 
               openCoordinate:(float)openCoord closeCoordinate:(float)closeCoord withWidth:(float)width
                    inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGRect rect;
    rect.origin.x = center - width/2;
    rect.origin.y = openCoord;
    rect.size.width = width;
    rect.size.height = closeCoord - openCoord;
    
    CGContextBeginPath(context);
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, center, maxCoord);
    CGContextAddLineToPoint(context, center, minCoord);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

+ (void)drawBarStockInRect:(CGRect)bounds
                   centerX:(float)center
         withMaxCoordinate:(float)maxCoord minCoordinate:(float)minCoord 
            openCoordinate:(float)openCoord closeCoordinate:(float)closeCoord withWidth:(float)width 
                 inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, center, maxCoord);
    CGContextAddLineToPoint(context, center, minCoord);
    CGContextMoveToPoint(context, center, openCoord);
    CGContextAddLineToPoint(context, center - width/2, openCoord);
    CGContextMoveToPoint(context, center, closeCoord);
    CGContextAddLineToPoint(context, center + width/2, closeCoord);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

+ (void)drawLineFromX:(float)x1 y:(float)y1 
                  toX:(float)x2 y:(float)y2
            inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
        
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

+ (void)drawRectangle:(CGRect)bounds
            inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextAddRect(context, bounds);
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext(); 
}

+ (void)drawPolyhedronForPoints:(CGPoint *)points
                          count:(size_t)count
                      inContext:(CGContextRef)context
{
    if (count) {
        UIGraphicsPushContext(context);
        
        CGContextBeginPath(context);
        
        CGContextMoveToPoint(context, points[0].x, points[0].y);
        for (int i = 1; i < count; i++) {
            CGContextAddLineToPoint(context, points[i].x, points[i].y);
        }
        
        CGContextEOFillPath(context);
        CGContextStrokePath(context);
        
        UIGraphicsPopContext(); 
    }
}

+ (void)setColorTo:(UIColor *)color
         inContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
}

@end
