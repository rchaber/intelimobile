//
//  QuoteTableViewCell.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/15/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "QuoteTableViewCell.h"
#import "SymbolStorage.h"

@interface QuoteTableViewCell()
{
    NSString *bidAskSizeText;
}
@property (nonatomic, copy) NSString *bidAskSizeText;
@end

@implementation QuoteTableViewCell
@synthesize symbolShortName;
@synthesize symbolLongName;
@synthesize symbolPriceNetChange;
@synthesize symbolPricePercentChange;
@synthesize symbolPrice;
@synthesize symbolBidSize;
@synthesize symbolBidPrice;
@synthesize symbolAskSize;
@synthesize symbolAskPrice;
@synthesize symbolHighPrice;
@synthesize symbolLowPrice;

@synthesize loadingLabel;
@synthesize errorLabel;
@synthesize bidAskSizeText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (BOOL)isCellLoading
{
    return (self.loadingLabel.hidden == NO);
}

- (BOOL)isError
{
    return !self.errorLabel.hidden;
}

- (void)enterEditingMode
{
    self.symbolShortName.frame = CGRectMake(self.symbolShortName.frame.origin.x, 11,
                                            self.symbolShortName.frame.size.width, self.symbolShortName.frame.size.height);
    
    self.symbolShortName.hidden = NO;
    
    self.symbolLongName.hidden = YES;
    self.symbolPriceNetChange.hidden = YES;
    self.symbolPricePercentChange.hidden = YES;
    self.symbolPrice.hidden = YES;
    self.symbolBidSize.hidden = YES;
    self.symbolBidPrice.hidden = YES;
    self.symbolAskSize.hidden = YES;
    self.symbolAskPrice.hidden = YES;
    self.symbolHighPrice.hidden = YES;
    self.symbolLowPrice.hidden = YES;
    
    self.loadingLabel.hidden = YES;
}

- (void)showLast
{
    self.symbolPrice.hidden = NO;
    self.symbolPriceNetChange.hidden = NO;
    self.symbolPricePercentChange.hidden = YES;
}

- (void)showLastPercent
{
    self.symbolPrice.hidden = NO;
    self.symbolPriceNetChange.hidden = YES;
    self.symbolPricePercentChange.hidden = NO;
}

- (void)showBidAsk
{
    self.symbolAskPrice.hidden = NO;
    self.symbolAskSize.hidden = NO;
    self.symbolBidPrice.hidden = NO;
    self.symbolBidSize.hidden = NO;
    self.symbolHighPrice.hidden = YES;
    self.symbolLowPrice.hidden = YES;
}

- (void)showHighLow
{
    self.symbolAskPrice.hidden = YES;
    self.symbolAskSize.hidden = YES;
    self.symbolBidPrice.hidden = YES;
    self.symbolBidSize.hidden = YES;
    self.symbolHighPrice.hidden = NO;
    self.symbolLowPrice.hidden = NO;
}

- (void)showLoadingAndHideAllSymbolInformation
{
    self.symbolShortName.hidden = YES;
    self.symbolLongName.hidden = YES;
    self.symbolPriceNetChange.hidden = YES;
    self.symbolPricePercentChange.hidden = YES;
    self.symbolPrice.hidden = YES;
    self.symbolBidSize.hidden = YES;
    self.symbolBidPrice.hidden = YES;
    self.symbolAskSize.hidden = YES;
    self.symbolAskPrice.hidden = YES;
    self.symbolHighPrice.hidden = YES;
    self.symbolLowPrice.hidden = YES;
    
    self.loadingLabel.hidden = NO;
}

- (void)hideLoading
{
    self.loadingLabel.hidden = YES;
}

- (void)showErrorLabelWithMessage:(NSString *)message
{
    self.errorLabel.hidden = NO;
    
    self.symbolShortName.hidden = YES;
    self.symbolLongName.hidden = YES;
    self.symbolPriceNetChange.hidden = YES;
    self.symbolPricePercentChange.hidden = YES;
    self.symbolPrice.hidden = YES;
    self.symbolBidSize.hidden = YES;
    self.symbolBidPrice.hidden = YES;
    self.symbolAskSize.hidden = YES;
    self.symbolAskPrice.hidden = YES;
    self.symbolHighPrice.hidden = YES;
    self.symbolLowPrice.hidden = YES;
    
    self.loadingLabel.hidden = YES;
    
    self.errorLabel.text = message;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateSymbolPriceNetChange:(NSString *)priceNetChange
{
    
    if ([priceNetChange doubleValue] < 0) {
        self.symbolPriceNetChange.textColor = [UIColor redColor];
    } else {
        self.symbolPriceNetChange.textColor = [UIColor greenColor];
    }
    self.symbolPriceNetChange.text = priceNetChange;
}

- (void)updateSymbolPricePercentChange:(NSString *)pricePercentChange
{
    if ([pricePercentChange doubleValue] < 0) {
        self.symbolPricePercentChange.textColor = [UIColor redColor];
    } else {
        self.symbolPricePercentChange.textColor = [UIColor greenColor];
    }
    self.symbolPricePercentChange.text = [NSString stringWithFormat:@"%@%%", pricePercentChange];
}

-(void)updateSymbol:(SymbolStorage *)aSymbol withName:(NSString *)name
{
    self.symbolShortName.text = name;
    self.symbolLongName.text = aSymbol.symbolLongName;
    self.symbolPrice.text = aSymbol.symbolPrice;
    [self updateSymbolPriceNetChange:aSymbol.symbolPriceNetChange];
    [self updateSymbolPricePercentChange:aSymbol.symbolPricePercentChange];
    self.symbolBidPrice.text = aSymbol.symbolBidPrice;
    self.symbolBidSize.text = [self.bidAskSizeText stringByAppendingFormat:@" %@", aSymbol.symbolBidSize];
    self.symbolAskPrice.text = aSymbol.symbolAskPrice;
    self.symbolAskSize.text = [self.bidAskSizeText stringByAppendingFormat:@" %@", aSymbol.symbolAskSize];
    self.symbolHighPrice.text = aSymbol.symbolHighPrice;
    self.symbolLowPrice.text = aSymbol.symbolLowPrice;
}

#pragma mark - View livecycle

- (void)localize
{
    NSMutableString *size = [NSMutableString stringWithString:NSLocalizedString(@"Size", nil)];
    size = [NSMutableString stringWithString:[size lowercaseString]];
    [size appendFormat:@":"];
    
    self.bidAskSizeText = size;
    self.loadingLabel.text = NSLocalizedString(@"Loading...", nil);
}

- (void)awakeFromNib
{
    [self localize];
}

@end
