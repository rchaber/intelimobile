//
//  ConfigureStudyButtonCell.m
//  StockQuotes
//
//  Created by Edward Khorkov on 11/1/11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import "ConfigureStudyButtonCell.h"

@interface ConfigureStudyButtonCell()
{
    UIButton *button;
    UILabel *label;
    NSUInteger index;
}
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UILabel *label;

- (IBAction)buttonPressed:(UIButton *)sender;
@end


@implementation ConfigureStudyButtonCell

#pragma mark - Livecycle

- (void)dealloc
{
    self.titles = nil;
}

#pragma mark - Properties

- (void)setTitles:(NSArray *)newTitles
{
    titles = newTitles;
    if ([titles count]) {
        index = 0;
        [self.button setTitle:[[titles objectAtIndex:index] uppercaseString] forState:UIControlStateNormal];
    }
}

#pragma mark - Methods

- (NSString *)currentTitle
{
    return [self.button.titleLabel.text lowercaseString];
}

- (void)setTitleAtIndex:(NSUInteger)i
{
    index = i;
    if (index >= [self.titles count]) {
        index = 0;
    }
    
    [self.button setTitle:[[self.titles objectAtIndex:index] uppercaseString] forState:UIControlStateNormal];
}

- (void)setLabelTextTo:(NSString *)text
{
    self.label.text = text;
}

- (IBAction)buttonPressed:(UIButton *)sender
{    
    if ([self.titles count]) {
        index++;
        if (index >= [self.titles count]) {
            index = 0;
        }
        
        [sender setTitle:[[self.titles objectAtIndex:index] uppercaseString] forState:UIControlStateNormal];
    }
}

@synthesize titles;
@synthesize button;
@synthesize label;

@end
