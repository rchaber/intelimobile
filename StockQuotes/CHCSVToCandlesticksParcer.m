//
//  CHCVToCandlesticksParcer.m
//  StockQuotes
//
//  Created by Edward Khorkov on 10/7/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "CHCSVToCandlesticksParser.h"
#import "CHCSVParser.h"

@interface CHCSVToCandlesticksParser()
{
    NSMutableArray *arrayOfCantablesticks;
    BOOL start;
}
@property (nonatomic, strong) NSMutableArray *arrayOfCantablesticks;
@end

@implementation CHCSVToCandlesticksParser
@synthesize arrayOfCantablesticks;

+ (NSArray *)parseNSURL:(NSURL *)url
{
    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    CHCSVParser *parser = [[CHCSVParser alloc] initWithCSVString:str encoding:NSUTF8StringEncoding error:nil];
 
    CHCSVToCandlesticksParser *CHCVtcp = [[CHCSVToCandlesticksParser alloc] init];
    parser.parserDelegate = CHCVtcp;
    [parser parse];
    NSArray *parsedArray = [CHCVtcp arrayOfCantablesticks];
    return parsedArray;
}

- (id)init
{
    if (self = [super init]) {
        start = NO;
        arrayOfCantablesticks = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) parser:(CHCSVParser *)parser didStartDocument:(NSString *)csvFile
{
    
}
- (void) parser:(CHCSVParser *)parser didStartLine:(NSUInteger)lineNumber
{
    
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber
{
    if (lineNumber == 1) {
        start = YES;
    }
}

- (void) parser:(CHCSVParser *)parser didReadField:(NSString *)field 
{
    if (start) {
        static int position = -1;
        position++;
        if (position == 6) {
            position = 0;
        }
        
        if (position == 0) {
            [self.arrayOfCantablesticks addObject:[NSMutableDictionary dictionary]];
            [[self.arrayOfCantablesticks lastObject] setObject:field forKey:@"date"];
        } else if (position == 1) {
            [[self.arrayOfCantablesticks lastObject] setObject:field forKey:@"open"];
        } else if (position == 2) {
            [[self.arrayOfCantablesticks lastObject] setObject:field forKey:@"max"];
        } else if (position == 3) {
            [[self.arrayOfCantablesticks lastObject] setObject:field forKey:@"min"];
        } else if (position == 4) {
            [[self.arrayOfCantablesticks lastObject] setObject:field forKey:@"close"];
        }
    }
}

- (void) parser:(CHCSVParser *)parser didEndDocument:(NSString *)csvFile 
{
    NSLog(@"Parsed");
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {}
@end
