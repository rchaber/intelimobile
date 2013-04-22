//
//  QuoteDetailViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkControllerProtocol.h"
#import "PlotDrawingView.h"
#import "ChartSetupViewController.h"

@class SymbolStorage;
@class NetworkController;

@interface QuoteDetailViewController : UIViewController <ChartSetupViewControllerDelegate>
{
    SymbolStorage *currentSymbol;
    UILabel *currentPrice;
    UILabel *pricePercentChange;
    UILabel *priceNetChange;
    UILabel *bidPrice;
    UILabel *bidSize;
    UILabel *askPrice;
    UILabel *askSize;
    UILabel *openPrice;
    UILabel *highPrice;
    UILabel *lowPrice;
    
    UILabel *bidSlashSizeLabel;
    UILabel *askSlashSizeLabel;
    UILabel *openLabel;
    UILabel *volumeLabel;
    UILabel *highLabel;
    UILabel *prevCloseLabel;
    UILabel *dollarVolumeLabel;
    UILabel *lowLabel;
    
    UIButton *testButtonClick;
    UIView *titleView;
    UILabel *titleShortName;
    UILabel *titleLongName;
    
    UIButton *quoteChartLeftButton;
    UIButton *quoteChartCenterButton;
    UIButton *quoteChartRightButton;
    
    UIView *movingView;
    UIScrollView *plotView;
    UIView *newsView;
    UIView *optionsView;
    
    UIButton *chartButton;
    UIButton *newsButton;
    UIButton *optionsButton;
    
    UILabel *blackLabel;
    UILabel *borderLabel;
    UIButton *plotShowButton;
    UIButton *plotHideButton;
    PlotDrawingView *plotDrawingAreaView;
    UIButton *setupChartButton;
}
@property (nonatomic, strong) IBOutlet UILabel *currentPrice;
@property (nonatomic, strong) IBOutlet UILabel *pricePercentChange;
@property (nonatomic, strong) IBOutlet UILabel *priceNetChange;
@property (nonatomic, strong) IBOutlet UILabel *bidPrice;
@property (nonatomic, strong) IBOutlet UILabel *bidSize;
@property (nonatomic, strong) IBOutlet UILabel *askPrice;
@property (nonatomic, strong) IBOutlet UILabel *askSize;
@property (nonatomic, strong) IBOutlet UILabel *openPrice;
@property (nonatomic, strong) IBOutlet UILabel *highPrice;
@property (nonatomic, strong) IBOutlet UILabel *lowPrice;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *volumeValue;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *prevClosePrice;

@property (nonatomic, strong) IBOutlet UILabel *bidSlashSizeLabel;
@property (nonatomic, strong) IBOutlet UILabel *askSlashSizeLabel;
@property (nonatomic, strong) IBOutlet UILabel *openLabel;
@property (nonatomic, strong) IBOutlet UILabel *volumeLabel;
@property (nonatomic, strong) IBOutlet UILabel *highLabel;
@property (nonatomic, strong) IBOutlet UILabel *prevCloseLabel;
@property (nonatomic, strong) IBOutlet UILabel *dollarVolumeLabel;
@property (nonatomic, strong) IBOutlet UILabel *lowLabel;

@property (nonatomic, strong) SymbolStorage *currentSymbol;

@property (nonatomic, strong) IBOutlet UIButton *quoteChartLeftButton;
@property (nonatomic, strong) IBOutlet UIButton *quoteChartCenterButton;
@property (nonatomic, strong) IBOutlet UIButton *quoteChartRightButton;

@property (nonatomic, strong) IBOutlet UIView *movingView;
@property (nonatomic, strong) IBOutlet UIScrollView *plotView;
@property (nonatomic, strong) IBOutlet UIView *newsView;
@property (nonatomic, strong) IBOutlet UIView *optionsView;

@property (nonatomic, strong) IBOutlet UIButton *chartButton;
@property (nonatomic, strong) IBOutlet UIButton *newsButton;
@property (nonatomic, strong) IBOutlet UIButton *optionsButton;

@property (nonatomic, strong) IBOutlet UILabel *blackLabel;
@property (nonatomic, strong) IBOutlet UILabel *borderLabel;
@property (nonatomic, strong) IBOutlet UIButton *plotShowButton;
@property (nonatomic, strong) IBOutlet UIButton *plotHideButton;
@property (nonatomic, strong) IBOutlet PlotDrawingView *plotDrawingAreaView;
@property (nonatomic, strong) IBOutlet UIButton *setupChartButton;

//custom title view properties
@property (nonatomic, strong) IBOutlet UIView *titleView;
@property (nonatomic, strong) IBOutlet UILabel *titleShortName;
@property (nonatomic, strong) IBOutlet UILabel *titleLongName;

- (void)updateViewWithSymbol:(SymbolStorage *)symbol;

- (IBAction)setupChartButtonPressed:(id)sender;
- (IBAction)plotShowHideButtonPressed:(id)sender;
- (IBAction)quoteChartButtonPressed:(id)sender;
- (IBAction)chartNewsOptionsButtonPressed:(id)sender;

@end


