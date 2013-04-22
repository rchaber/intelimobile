//
//  QuoteTableViewCell.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/15/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SymbolStorage;

@interface QuoteTableViewCell : UITableViewCell {
    UILabel *symbolShortName;
    UILabel *symbolLongName;
    UILabel *symbolPriceNetChange;
    UILabel *symbolPricePercentChange;
    UILabel *symbolPrice;
    UILabel *symbolBidSize;
    UILabel *symbolBidPrice;
    UILabel *symbolAskSize;
    UILabel *symbolAskPrice;
    UILabel *symbolHighPrice;
    UILabel *symbolLowPrice;
    
    UILabel *loadingLabel;
    UILabel *errorLabel;
}

@property (nonatomic, strong) IBOutlet UILabel *symbolShortName;
@property (nonatomic, strong) IBOutlet UILabel *symbolLongName;
@property (nonatomic, strong) IBOutlet UILabel *symbolPriceNetChange;
@property (nonatomic, strong) IBOutlet UILabel *symbolPricePercentChange;
@property (nonatomic, strong) IBOutlet UILabel *symbolPrice;
@property (nonatomic, strong) IBOutlet UILabel *symbolBidSize;
@property (nonatomic, strong) IBOutlet UILabel *symbolBidPrice;
@property (nonatomic, strong) IBOutlet UILabel *symbolAskSize;
@property (nonatomic, strong) IBOutlet UILabel *symbolAskPrice;
@property (nonatomic, strong) IBOutlet UILabel *symbolHighPrice;
@property (nonatomic, strong) IBOutlet UILabel *symbolLowPrice;

@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;

- (BOOL)isCellLoading;
- (BOOL)isError;

// shows only symbol
- (void)enterEditingMode;

- (void)showLast;
- (void)showLastPercent;

- (void)showBidAsk;
- (void)showHighLow;

- (void)showLoadingAndHideAllSymbolInformation;
- (void)hideLoading;

- (void)showErrorLabelWithMessage:(NSString *)message;

-(void)updateSymbol:(SymbolStorage *)aSymbol withName:(NSString *)name;

@end
