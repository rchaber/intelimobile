//
//  HorizontalPicker.h
//  StockQuotes
//
//  Created by Edward Khorkov on 10/12/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HorizontalPicker;

@protocol HorizontalPickerDelegate <NSObject>
@required
- (void)horisontalPicker:(HorizontalPicker *)picker hasSelected:(NSInteger)number;

@end

@interface HorizontalPicker : NSObject <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    id <HorizontalPickerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, unsafe_unretained) id <HorizontalPickerDelegate> delegate;

- (id)initWithArrayOfNSString:(NSArray *)array andFrame:(CGRect)frame;
- (id)initWithArrayOfNSString:(NSArray *)array andFrame:(CGRect)frame cycled:(BOOL)cycled;

- (void)selectObjectAtIndex:(NSUInteger)index;
- (void)selectObjectNamed:(NSString *)name;
- (NSString *)selectedString;

@end
