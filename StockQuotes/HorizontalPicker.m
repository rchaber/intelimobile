//
//  HorizontalPicker.m
//  StockQuotes
//
//  Created by Edward Khorkov on 10/12/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HorizontalPicker.h"

@interface HorizontalPicker()
{
    NSMutableArray *arrayOfLabels;
    NSInteger selectedIndex;
}

@property (nonatomic, strong) NSMutableArray *arrayOfLabels;

@property (nonatomic, unsafe_unretained) BOOL cycled;

- (void)moveScrollToCenterOfCurrentTextForView:(UIScrollView *)sView animated:(BOOL)animated animationName:(NSString *)animationName;
@end

@implementation HorizontalPicker
@synthesize scrollView;
@synthesize delegate;

@synthesize arrayOfLabels;
@synthesize cycled = _cycled;

#pragma mark - Picker lifecycle;

- (id)initWithArrayOfNSString:(NSArray *)array andFrame:(CGRect)frame
{
    return [self initWithArrayOfNSString:array andFrame:frame cycled:NO];
}

- (id)initWithArrayOfNSString:(NSArray *)_array andFrame:(CGRect)frame cycled:(BOOL)cycled
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_array];
    if (cycled && [array count]) {
        self.cycled = YES;
        [array insertObject:[array lastObject] atIndex:0];
        [array addObject:[array objectAtIndex:1]];
    }
    
    if (self = [super init]) {
        UIScrollView *sView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.origin.x + 3, frame.origin.y,
                                                                             frame.size.width - 6, frame.size.height)];
        self.scrollView = sView;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        float contentWidth = [array count] * self.scrollView.frame.size.width;
        self.scrollView.contentSize = CGSizeMake(contentWidth, self.scrollView.frame.size.height);
        self.scrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = NO;
        self.scrollView.bounces = NO;
        self.scrollView.delegate = self;
        
        arrayOfLabels = [[NSMutableArray alloc] init];
        
        int i = 0;
        for (NSString *string in array) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*self.scrollView.frame.size.width, 0, 
                                                                       self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
            label.text = string;
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            [self.arrayOfLabels addObject:label];
            [self.scrollView addSubview:label];
            i++;
        }
    }
    return self;
}


#pragma mark - Methods

- (void)selectObjectAtIndex:(NSUInteger)index
{
    if (index >= [self.arrayOfLabels count]) return;
    
    selectedIndex = index;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * index, 0.0f)];
}

- (void)selectObjectNamed:(NSString *)name
{
    int from = 0;
    int to = [self.arrayOfLabels count];
    
    if (self.cycled) {
        from++;
        to--;
    }
    
    for (int index = from; index < to; index++) {
        if ([name isEqualToString:[[self.arrayOfLabels objectAtIndex:index] text]]) {
            [self selectObjectAtIndex:index];
            break;
        }
    }
}

- (NSString *)selectedString;
{
    return [[self.arrayOfLabels objectAtIndex:selectedIndex] text];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)sView willDecelerate:(BOOL)decelerate 
{
    NSInteger number = (NSInteger) ((sView.contentOffset.x +sView.frame.size.width/2) / sView.frame.size.width);
    selectedIndex = number;
    NSString *animationName = @"";
    
    if (self.cycled) {
        if (selectedIndex == [self.arrayOfLabels count] - 1) {
            selectedIndex = 1;
            number = 1;
            animationName = @"moveScrollViewLastObject";
        }
        else if (selectedIndex == 0) {
            selectedIndex = [self.arrayOfLabels count] - 2;
            number = selectedIndex;
            animationName = @"moveScrollViewFirstObject";
        }
    }

    [self moveScrollToCenterOfCurrentTextForView:sView animated:YES animationName:animationName];
    [self.delegate horisontalPicker:self hasSelected:number];
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)sView
{  
    [sView setContentOffset:sView.contentOffset animated:YES];   
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([@"moveScrollViewLastObject" isEqualToString:animationID]) {
        UIScrollView *sView = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
        sView.contentOffset = self.scrollView.contentOffset;
        sView.contentOffset = CGPointMake(1.5 * sView.frame.size.width, sView.contentOffset.y);
        [self moveScrollToCenterOfCurrentTextForView:sView animated:NO animationName:nil];
    }
    else if ([@"moveScrollViewFirstObject" isEqualToString:animationID]) {
        UIScrollView *sView = [[UIScrollView alloc] initWithFrame:self.scrollView.frame];
        sView.contentOffset = self.scrollView.contentOffset;
        sView.contentSize = self.scrollView.contentSize;
        sView.contentOffset = CGPointMake(sView.contentSize.width - 1.5 * sView.frame.size.width, sView.contentOffset.y);
        [self moveScrollToCenterOfCurrentTextForView:sView animated:NO animationName:nil];
    }
}

#pragma mark - Supporting methods

- (void)moveScrollToCenterOfCurrentTextForView:(UIScrollView *)sView animated:(BOOL)animated animationName:(NSString *)animationName
{
    float delta = sView.contentOffset.x;
    while (delta > sView.frame.size.width) {
        delta -= sView.frame.size.width;
    }
    
    if (delta > sView.frame.size.width/2) {
        delta = delta - sView.frame.size.width;
    }
    float x = sView.contentOffset.x - delta;
   
    if (animated) {
        [UIView beginAnimations:animationName context:NULL];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
    }
    [self.scrollView setContentOffset:CGPointMake(x, 0.0f)];
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
