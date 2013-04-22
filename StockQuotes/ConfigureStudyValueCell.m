//
//  ConfigureStudyValueCell.m
//  StockQuotes
//
//  Created by Edward Khorkov on 11/1/11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import "ConfigureStudyValueCell.h"

@interface ConfigureStudyValueCell()
{
    UILabel *label;
    
    UIButton *minusButton;
    UIButton *plusButton;
    UITextField *textField;
    
    CGFloat minimum;
    CGFloat maximum;
    CGFloat delta;
}
@property (nonatomic, strong) IBOutlet UILabel *label;

@property (nonatomic, strong) IBOutlet UIButton *minusButton;
@property (nonatomic, strong) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (IBAction)minusButtonPressed:(UIButton *)sender;
- (IBAction)plusButtonPressed:(UIButton *)sender;
@end

@implementation ConfigureStudyValueCell

#pragma mark - Methods

- (void)setMinimumValue:(CGFloat)min andMaximumValue:(CGFloat)max
{
    if (min < max) {
        minimum = min;
        maximum = max;
    }
}

- (void)setCurrentValue:(CGFloat)value
{
    textField.text = [NSString stringWithFormat:@"%g", value];
    if (value <= minimum) {
        self.minusButton.enabled = NO;
    }
    if (value >= maximum) {
        self.plusButton.enabled = NO;
    }
}

- (void)setDelta:(CGFloat)newDelta
{
    delta = newDelta;
}

- (CGFloat)currentValue
{
    return [textField.text floatValue];
}

- (IBAction)minusButtonPressed:(UIButton *)sender
{
    CGFloat newValue = [textField.text floatValue] - delta;
    textField.text = [NSString stringWithFormat:@"%g", newValue];
    
    if (newValue <= minimum) {
        self.minusButton.enabled = NO;
    }
    self.plusButton.enabled = YES;
}

- (IBAction)plusButtonPressed:(UIButton *)sender
{
    CGFloat newValue = [textField.text floatValue] + delta;
    textField.text = [NSString stringWithFormat:@"%g", newValue];
    
    if (newValue >= maximum) {
        self.plusButton.enabled = NO;
    }
    self.minusButton.enabled = YES;
}

- (void)setLabelTextTo:(NSString *)text
{
    self.label.text = text;
}

#pragma mark - TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)tField
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(configureStudyValueCell:wasPressedTextField:)]) {
            [self.delegate configureStudyValueCell:self wasPressedTextField:tField];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)tField
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(configureStudyValueCell:endEditingTextField:)]) {
            [self.delegate configureStudyValueCell:self endEditingTextField:tField];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)tField
{
    if ([tField.text floatValue] < minimum) {
        tField.text = [NSString stringWithFormat:@"%g", minimum];
    } else if ([tField.text floatValue] > maximum) {
        tField.text = [NSString stringWithFormat:@"%g", maximum];
    } 
    [self.textField resignFirstResponder]; 
    return YES;
}

@synthesize label;
@synthesize delegate;

@synthesize minusButton, plusButton, textField;
@end
