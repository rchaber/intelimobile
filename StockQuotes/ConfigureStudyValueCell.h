//
//  ConfigureStudyValueCell.h
//  StockQuotes
//
//  Created by Edward Khorkov on 11/1/11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureStudyCell.h"

@class ConfigureStudyValueCell;
@protocol ConfigureStudyValueCellDelegate <NSObject>
@optional
- (void)configureStudyValueCell:(ConfigureStudyValueCell *)cell wasPressedTextField:(UITextField *)textField;
- (void)configureStudyValueCell:(ConfigureStudyValueCell *)cell endEditingTextField:(UITextField *)textField;
@end

@interface ConfigureStudyValueCell : ConfigureStudyCell <UITextFieldDelegate>
{
    id <ConfigureStudyValueCellDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, unsafe_unretained) id <ConfigureStudyValueCellDelegate> delegate;

- (void)setMinimumValue:(CGFloat)min andMaximumValue:(CGFloat)max;
- (void)setCurrentValue:(CGFloat)value;
- (void)setDelta:(CGFloat)delta;

- (CGFloat)currentValue;
@end
