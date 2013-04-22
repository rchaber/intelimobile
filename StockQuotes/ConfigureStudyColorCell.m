//
//  ConfigureStudyColorCell.m
//  StockQuotes
//
//  Created by Edward Khorkov on 11/1/11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import "ConfigureStudyColorCell.h"

@interface ConfigureStudyColorCell()
{
    UIImageView *colorSelector;
    UILabel *label;
    UIColor *currentColor;
}
@property (nonatomic, strong) IBOutlet UIImageView *colorSelector;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) UIColor *currentColor;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *red;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *blue;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *green;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *yellow;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *orange;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pink;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *brownish;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *purple;

- (IBAction)colorButtonPressed:(UIButton *)sender;

@end

@implementation ConfigureStudyColorCell

#pragma mark - Livecycle

- (void)awakeFromNib
{
    self.currentColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
}


#pragma mark - methods

- (UIColor *)chosenColor
{
    return self.currentColor;
}

- (void)setColorTo:(UIColor *)color
{
    if ([color isEqual:self.red.backgroundColor]) {
        [self colorButtonPressed:self.red];
    } else if ([color isEqual:self.blue.backgroundColor]) {
        [self colorButtonPressed:self.blue];
    } else if ([color isEqual:self.green.backgroundColor]) {
        [self colorButtonPressed:self.green];
    } else if ([color isEqual:self.yellow.backgroundColor]) {
        [self colorButtonPressed:self.yellow];
    } else if ([color isEqual:self.orange.backgroundColor]) {
        [self colorButtonPressed:self.orange];
    } else if ([color isEqual:self.pink.backgroundColor]) {
        [self colorButtonPressed:self.pink];
    } else if ([color isEqual:self.brownish.backgroundColor]) {
        [self colorButtonPressed:self.brownish];
    } else if ([color isEqual:self.purple.backgroundColor]) {
        [self colorButtonPressed:self.purple];
    }
}

- (IBAction)colorButtonPressed:(UIButton *)sender
{
    self.currentColor = sender.backgroundColor;
    
    CGRect frame = self.colorSelector.frame;
    frame.origin.x = sender.frame.origin.x - 2;
    frame.origin.y = sender.frame.origin.y - 2;
    
    [UIView beginAnimations:@"colorSelectorAnimation" context:nil];
    [UIView setAnimationDuration:0.1];
    self.colorSelector.frame = frame;
    [UIView commitAnimations];
}

- (void)setLabelTextTo:(NSString *)text
{
    self.label.text = text;
}

@synthesize colorSelector;
@synthesize label;
@synthesize currentColor;
@synthesize red = _red;
@synthesize blue = _blue;
@synthesize green = _green;
@synthesize yellow = _yellow;
@synthesize orange = _orange;
@synthesize pink = _pink;
@synthesize brownish = _brownish;
@synthesize purple = _purple;

@end
