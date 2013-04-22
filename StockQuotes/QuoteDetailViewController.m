//
//  QuoteDetailViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "QuoteDetailViewController.h"
#import "NetworkController.h"
#import "SymbolStorage.h"
#import "CHCSVToCandlesticksParser.h"
#import "OrderEditorViewController.h"
#import "ChartSetupViewController.h"

#define PLOT_VIEW_PARTLY_HIDDEN_COORDINATE_Y 150

@interface QuoteDetailViewController()
{
    //defined in ChartSetupViewController.h
    ChartType chartType;
    NSUInteger barsToRight;
    
    NSMutableArray *arrayOfCandlesticks;
    OrderEditorViewController *orderEditorViewController;
    
    BOOL wasLoaded;
}
@property (nonatomic, strong) NSMutableArray *arrayOfCandlesticks;

- (void)loadStandartUserDefaults;
- (void)localize;
- (void)createBarButtonItems;
- (UIButton *)createOrangeButton;
- (void)configureBorderLabel;
- (void)configureTitleView;
- (void)parseCsvFile;
- (void)configureMovingView;
- (void)configurePlotView;
- (void)addGestureRecognizers;
- (void)setMinorLabelsHiddenPropertyTo:(BOOL)state;
- (void)beginAnimationWithName:(NSString *)name andDelay:(NSTimeInterval)delay;
- (void)setEnabledOptionForLeft:(BOOL)le center:(BOOL)ce rightButtons:(BOOL)re;
- (void)setEnabledOptionForChart:(BOOL)ce news:(BOOL)ne optionButtons:(BOOL)oe;
- (void)setHiddenOptionForPlot:(BOOL)ph news:(BOOL)nh optionsViews:(BOOL)oh;
- (void)setStandartUserDefaultsChartTypeTo:(ChartType)type;
- (void)createCharts;
- (BOOL)isMovingViewExpanded;
- (void)drawNetChange:(NSString *)netChange andPercentChange:(NSString *)persentChange;
- (void)setChartTypeTo:(NSString *)type;
@end

@implementation QuoteDetailViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // for case if OrderEditorViewController poped from NavigationController
    // OEVC is released now, we don't want to resend messages to it
    orderEditorViewController = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    if(self.currentSymbol) {
        [self updateViewWithSymbol:self.currentSymbol];
    }
    if (wasLoaded) {
        [self createCharts];
    } else {
        wasLoaded = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStandartUserDefaults];
    [self localize];
    [self createBarButtonItems];
    [self configureBorderLabel];
    [self configureTitleView];
    [self parseCsvFile];
    [self configureMovingView];
    [self addGestureRecognizers];
}

#pragma mark - Instance methods



- (void)updateViewWithSymbol:(SymbolStorage *)symbol
{
    self.titleShortName.text = self.currentSymbol.symbolShortName;
    self.titleLongName.text = self.currentSymbol.symbolLongName;
    
    self.currentPrice.text = symbol.symbolPrice;
    
    [self drawNetChange:symbol.symbolPriceNetChange andPercentChange:symbol.symbolPricePercentChange];
    
    self.bidPrice.text = symbol.symbolBidPrice;
    self.bidSize.text = symbol.symbolBidSize;
    self.askPrice.text = symbol.symbolAskPrice;
    self.askSize.text = symbol.symbolAskSize;
    self.openPrice.text = symbol.symbolOpenPrice;
    self.highPrice.text = symbol.symbolHighPrice;
    self.lowPrice.text = symbol.symbolLowPrice;
    self.prevClosePrice.text = symbol.symbolPrevClosingPrice;
    self.volumeValue.text = symbol.symbolTradeVolume;

    [orderEditorViewController updateViewWithSymbol:symbol];
}

#pragma mark - Gesture recognizers

- (void)panGestureOnDrawingArea:(UIPanGestureRecognizer *)gesture
{
//    NSLog(@"%f", [gesture velocityInView:self.plotView].x);
//    float delta = [gesture translationInView:self.plotView].x;
    float delta = [gesture velocityInView:self.plotView].x / 30;
    
    NSRange newRange = self.plotDrawingAreaView.rangeToDraw;
    float widthOccupiedByCandle = self.plotDrawingAreaView.candlestickDrawer.widthOccupiedByCandle;
    float deltaDivWidth = delta / widthOccupiedByCandle;
    newRange.location += (int) deltaDivWidth;

    self.plotDrawingAreaView.rangeToDraw = newRange;
    [self.plotDrawingAreaView setNeedsDisplay];
    
    [gesture setTranslation:CGPointZero inView:self.plotView];
}

#pragma mark - Animation delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([@"ShowPlotViewAnimation" isEqual:animationID]) {
        self.plotShowButton.hidden = YES;
        self.plotHideButton.hidden = NO;
    } else if ([@"HidePlotViewAnimation" isEqual:animationID]) {
        [self setMinorLabelsHiddenPropertyTo:NO];
        self.plotShowButton.hidden = NO;
        self.plotHideButton.hidden = YES;
        self.pricePercentChange.hidden = NO;
        [self updateViewWithSymbol:self.currentSymbol];
    }
}

#pragma mark - Buttons

- (IBAction)setupChartButtonPressed:(id)sender
{
    ChartSetupViewController *csvc = [[ChartSetupViewController alloc] init];
    csvc.delegate = self;
    [self.navigationController pushViewController:csvc animated:YES];
}

- (IBAction)plotShowHideButtonPressed:(id)sender
{
    if ([sender isEqual:self.plotShowButton]) {
        // for case if Chart|News|Options" Buttons will be in moving view
//        NSUInteger yCoordinate = self.view.bounds.size.height - self.movingView.frame.size.height;
        NSUInteger yCoordinate = 70;
        
        [self beginAnimationWithName:@"ShowPlotViewAnimation" andDelay:0.1];
        
        [self setMinorLabelsHiddenPropertyTo:YES];
        self.blackLabel.frame = CGRectMake(0, 0, 320, 58);
        self.borderLabel.frame = CGRectMake(self.borderLabel.frame.origin.x, self.borderLabel.frame.origin.y, 
                                            self.borderLabel.frame.size.width, 50);
        self.movingView.frame = CGRectMake(0, yCoordinate, self.movingView.frame.size.width, self.movingView.frame.size.height);
        
        NSString *bid = NSLocalizedString(@"Bid", nil);
        NSString *ask = NSLocalizedString(@"Ask", nil);
        self.bidSlashSizeLabel.text = [bid stringByAppendingFormat:@":"];
        self.askSlashSizeLabel.text = [ask stringByAppendingFormat:@":"];
        
        self.pricePercentChange.hidden = YES;
        [self updateViewWithSymbol:self.currentSymbol];

        [UIView commitAnimations];
        
    } else if ([sender isEqual:self.plotHideButton]) {
        [self beginAnimationWithName:@"HidePlotViewAnimation" andDelay:0.1];
        
        self.blackLabel.frame = CGRectMake(0, 0, 320, PLOT_VIEW_PARTLY_HIDDEN_COORDINATE_Y-1);
        self.borderLabel.frame = CGRectMake(self.borderLabel.frame.origin.x, self.borderLabel.frame.origin.y, 
                                            self.borderLabel.frame.size.width, 130);
        self.movingView.frame = CGRectMake(0, PLOT_VIEW_PARTLY_HIDDEN_COORDINATE_Y, self.movingView.frame.size.width, self.movingView.frame.size.height);
        
        NSString *bid = NSLocalizedString(@"Bid", nil);
        NSString *ask = NSLocalizedString(@"Ask", nil);
        NSString *size = NSLocalizedString(@"Size", nil);
        self.bidSlashSizeLabel.text = [bid stringByAppendingFormat:@"/%@:", size];
        self.askSlashSizeLabel.text = [ask stringByAppendingFormat:@"/%@:", size];
        
        [UIView commitAnimations];
    }
}

- (IBAction)quoteChartButtonPressed:(id)sender
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *period;
    NSString *interval;
    NSString *aggregation;
    
    if ([sender isEqual:self.quoteChartLeftButton]) {
        [self setEnabledOptionForLeft:NO center:YES rightButtons:YES];
        period = @"1 Day";
        interval = @"5 Min";
        aggregation = @"intraday";
    } else if ([sender isEqual:self.quoteChartCenterButton]) {
        [self setEnabledOptionForLeft:YES center:NO rightButtons:YES];
        period = @"3 Months";
        interval = @"1 Day";
        aggregation = @"daily";
    } else if ([sender isEqual:self.quoteChartRightButton]) {
        [self setEnabledOptionForLeft:YES center:YES rightButtons:NO];
        period = @"1 Year";
        interval = @"1 Week";
        aggregation = @"daily";
    }
    
    NSMutableDictionary *chartOptions = [NSMutableDictionary dictionaryWithDictionary:[standartUserDefaults objectForKey:@"chartOptions"]];
    
    if (period && interval && aggregation) {
        [chartOptions setObject:period forKey:@"period"];
        [chartOptions setObject:interval forKey:@"interval"];
        [chartOptions setObject:aggregation forKey:@"aggregation"];
        [standartUserDefaults setObject:chartOptions forKey:@"chartOptions"];
        [standartUserDefaults synchronize];
    }
}

- (IBAction)chartNewsOptionsButtonPressed:(id)sender
{
    if ([sender isEqual:self.chartButton]) {
        [self setEnabledOptionForChart:NO news:YES optionButtons:YES];
        [self setHiddenOptionForPlot:NO news:YES optionsViews:YES];
    } else if ([sender isEqual:self.newsButton]) {
        [self setEnabledOptionForChart:YES news:NO optionButtons:YES];
        [self setHiddenOptionForPlot:YES news:NO optionsViews:YES];
    } else if ([sender isEqual:self.optionsButton]) {
        [self setEnabledOptionForChart:YES news:YES optionButtons:NO];
        [self setHiddenOptionForPlot:YES news:YES optionsViews:NO];
    }
}

- (void)tradeButtonPressed
{
    OrderEditorViewController *oevc = [[OrderEditorViewController alloc] initWithNibName:@"OrderEditorViewController" bundle:nil];
    orderEditorViewController = oevc;
    [self.navigationController pushViewController:oevc animated:YES];
    [oevc updateViewWithSymbol:self.currentSymbol];
}

#pragma mark - Custom Getters/Setters

- (void)setCurrentSymbol:(SymbolStorage *)newSymbol
{
    if (currentSymbol == newSymbol)
        return;
    
    currentSymbol = newSymbol;
    
}

#pragma mark - ChartSetupViewController delegate

- (void)chartSetupViewControllerhasChangedUserDefaults:(ChartSetupViewController *)controller
{
    [self loadStandartUserDefaults];
    [self configurePlotView];
    [self.plotDrawingAreaView setNeedsDisplay];
}

#pragma mark - Supporting methods

- (void)loadStandartUserDefaults
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *chartTypeName = [[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"type"];
    [self setChartTypeTo:chartTypeName];
    
    barsToRight = [[[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"barsToRight"] integerValue];
    if (! barsToRight) {
        barsToRight = 3;
    }
}

- (void)localize
{
    NSString *bid = NSLocalizedString(@"Bid", nil);
    NSString *ask = NSLocalizedString(@"Ask", nil);
    NSString *size = NSLocalizedString(@"Size", nil);
    bidSlashSizeLabel.text = [bid stringByAppendingFormat:@"/%@:", size];
    askSlashSizeLabel.text = [ask stringByAppendingFormat:@"/%@:", size];
    
    NSString *open = NSLocalizedString(@"Open", nil);
    NSString *volume = NSLocalizedString(@"Volume", nil);
    NSString *high = NSLocalizedString(@"High", nil);
    NSString *prevClose = NSLocalizedString(@"Prev.Close", nil);
    NSString *dollarVolume = NSLocalizedString(@"$ Volume", nil);
    NSString *low = NSLocalizedString(@"Low", nil);
    openLabel.text = [open stringByAppendingFormat:@":"];
    volumeLabel.text = [volume stringByAppendingFormat:@":"];
    highLabel.text = [high stringByAppendingFormat:@":"];
    prevCloseLabel.text = [prevClose stringByAppendingFormat:@":"];
    dollarVolumeLabel.text = [dollarVolume stringByAppendingFormat:@":"];
    lowLabel.text = [low stringByAppendingFormat:@":"];
    
    NSString *min = NSLocalizedString(@"min", nil);
    NSString *day = NSLocalizedString(@"Day", nil);
    NSString *mon = NSLocalizedString(@"Mon", nil);
    NSString *week = NSLocalizedString(@"Week", nil);
    NSString *year = NSLocalizedString(@"Yr", nil);
    [self.quoteChartLeftButton setTitle:[NSString stringWithFormat:@"1%@:5%@", day, min] forState:UIControlStateNormal];
    [self.quoteChartCenterButton setTitle:[NSString stringWithFormat:@"3%@:%@", mon, day] forState:UIControlStateNormal];
    [self.quoteChartRightButton setTitle:[NSString stringWithFormat:@"1%@:%@", year, week] forState:UIControlStateNormal];
    [self.setupChartButton setTitle:NSLocalizedString(@"Setup Chart", nil) forState:UIControlStateNormal];
    
    [self.chartButton setTitle:NSLocalizedString(@"Chart", nil) forState:UIControlStateNormal];
    [self.newsButton setTitle:NSLocalizedString(@"News", nil) forState:UIControlStateNormal];
    [self.optionsButton setTitle:NSLocalizedString(@"Options", nil) forState:UIControlStateNormal];
}

- (void)createBarButtonItems
{
    UIButton *orangeButton = [self createOrangeButton];
    UIBarButtonItem *tradeButton = [[UIBarButtonItem alloc] initWithCustomView:orangeButton];
    self.navigationItem.rightBarButtonItem = tradeButton;
}

- (UIButton *)createOrangeButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_orange_gradient.png"] forState:UIBarButtonItemStylePlain];
    [button setTitle:NSLocalizedString(@"Trade", nil) forState:UIBarButtonItemStylePlain];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    button.titleLabel.shadowColor = [UIColor blackColor];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor: [[UIColor grayColor] CGColor]];
    button.frame=CGRectMake(0.0, 100.0, 55.0, 30.0);
    [button addTarget:self action:@selector(tradeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)configureBorderLabel
{
    self.borderLabel.layer.cornerRadius = 7;
    self.borderLabel.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    self.borderLabel.layer.borderWidth = 1;
}

- (void)configureTitleView
{

    self.titleShortName.text = self.currentSymbol.symbolShortName;
    self.titleLongName.text = self.currentSymbol.symbolLongName;
    
    self.navigationItem.titleView = self.titleView;
}

- (void)parseCsvFile
{
    dispatch_queue_t parseQueue = dispatch_queue_create("Parse queue", NULL);
    dispatch_async(parseQueue, ^{
        NSURL *file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/data.csv.xls", [[NSBundle mainBundle] resourcePath]]];
        self.arrayOfCandlesticks = [NSMutableArray arrayWithArray:[CHCSVToCandlesticksParser parseNSURL:file]];

        [self.plotDrawingAreaView setCandlesticks:self.arrayOfCandlesticks];
        if (dispatch_get_main_queue() == dispatch_get_current_queue()) {
            [self createCharts];
            [self.plotDrawingAreaView setNeedsDisplay];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self createCharts];
                [self.plotDrawingAreaView setNeedsDisplay];
            });
        }
    });
    dispatch_release(parseQueue);
}

- (void)configureMovingView
{
    [self.view addSubview:self.movingView];
    [self.view sendSubviewToBack:self.movingView];
    self.movingView.frame = CGRectMake(0, PLOT_VIEW_PARTLY_HIDDEN_COORDINATE_Y, self.movingView.frame.size.width, self.movingView.frame.size.height);
    self.plotHideButton.hidden = YES;
    [self configurePlotView];
    [self setHiddenOptionForPlot:NO news:YES optionsViews:YES];
}

- (void)configurePlotView
{
    NSRange rangeToDraw;
    rangeToDraw.length = 60 - barsToRight;
    rangeToDraw.location = 0;
    self.plotDrawingAreaView.rangeToDraw = rangeToDraw;
    self.plotDrawingAreaView.barsToRight = barsToRight;
    
    if (chartType == ChartTypeBar) {
        [self.plotDrawingAreaView drawBars];
    } else if (chartType == ChartTypeCandle) {
        [self.plotDrawingAreaView drawCandles];
    } else if (chartType == ChartTypeLine) {
        [self.plotDrawingAreaView drawLines];
    } else if (chartType == ChartTypeArea) {
        [self.plotDrawingAreaView drawArea];
    }
}

- (void)addGestureRecognizers
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOnDrawingArea:)];
    [self.plotDrawingAreaView addGestureRecognizer:panGestureRecognizer];
}

- (void)setMinorLabelsHiddenPropertyTo:(BOOL)state
{
    self.openLabel.hidden = state;
    self.openPrice.hidden = state;
    self.volumeLabel.hidden = state;
    self.volumeValue.hidden = state;
    self.highLabel.hidden = state;
    self.highPrice.hidden = state;
    self.prevCloseLabel.hidden = state;
    self.prevClosePrice.hidden = state;
    self.dollarVolumeLabel.hidden = state;
    self.lowLabel.hidden = state;
    self.lowPrice.hidden = state;
    self.bidSize.hidden = state;
    self.askSize.hidden = state;
}

- (void)beginAnimationWithName:(NSString *)name andDelay:(NSTimeInterval)delay
{
    [UIView beginAnimations:name context:NULL];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
}

- (void)setEnabledOptionForLeft:(BOOL)le center:(BOOL)ce rightButtons:(BOOL)re
{
    self.quoteChartLeftButton.enabled = le;
    self.quoteChartCenterButton.enabled = ce;
    self.quoteChartRightButton.enabled = re;
}

- (void)setEnabledOptionForChart:(BOOL)ce news:(BOOL)ne optionButtons:(BOOL)oe
{
    self.chartButton.enabled = ce;
    self.newsButton.enabled = ne;
    self.optionsButton.enabled = oe;
}

- (void)setHiddenOptionForPlot:(BOOL)ph news:(BOOL)nh optionsViews:(BOOL)oh
{
    self.plotView.hidden = ph;
    self.newsView.hidden = nh;
    self.optionsView.hidden = oh;
}

- (void)setStandartUserDefaultsChartTypeTo:(ChartType)type
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *chartOptions = [NSMutableDictionary dictionaryWithDictionary:[standartUserDefaults objectForKey:@"chartOptions"]];
    if (!chartOptions) {
        chartOptions = [NSMutableDictionary dictionary];
    }
    
    NSString *chartTypeName;
    if (type == ChartTypeBar) {
        chartTypeName = @"Bar";
    } else if (type == ChartTypeCandle) {
        chartTypeName = @"Candle";
    } else if (type == ChartTypeLine) {
        chartTypeName = @"Line";
    } else if (type == ChartTypeArea) {
        chartTypeName = @"Area";
    }
    
    [chartOptions setObject:chartTypeName forKey:@"type"];
    [standartUserDefaults setObject:chartOptions forKey:@"chartOptions"];
}

- (void)createCharts
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayOfCharts = [NSMutableArray array];
    NSDictionary *dict = [standartUserDefaults objectForKey:@"studyButtons"];
    
    if ([dict objectForKey:@"first"]) {
        NSDictionary *chart = [NSDictionary dictionaryWithObjectsAndKeys:
                               [dict objectForKey:@"first"], @"name",
                               [dict objectForKey:@"firstOptions"], @"options",
                               nil];
        [arrayOfCharts addObject:chart];        
    }
    
    if ([dict objectForKey:@"second"]) {
        NSDictionary *chart = [NSDictionary dictionaryWithObjectsAndKeys:
                               [dict objectForKey:@"second"], @"name",
                               [dict objectForKey:@"secondOptions"], @"options",
                               nil];
        [arrayOfCharts addObject:chart];        
    }         
    
    if ([arrayOfCharts count]) {
        [self.plotDrawingAreaView drawChartsForArrayOfChartsNamesAndOptions:arrayOfCharts];
        [self.plotDrawingAreaView setNeedsDisplay];
    }
    
    if ([dict objectForKey:@"lowerStudy"]) {
        [self.plotDrawingAreaView setLowerStudyTo:[dict objectForKey:@"lowerStudy"] 
                                      withOptions:[dict objectForKey:@"lowerStudyOptions"]];
    }
}

- (BOOL)isMovingViewExpanded
{
    return (self.movingView.frame.origin.y == PLOT_VIEW_PARTLY_HIDDEN_COORDINATE_Y);
}

- (void)drawNetChange:(NSString *)netChange andPercentChange:(NSString *)persentChange
{
    if ([self isMovingViewExpanded]) {
        if ([netChange floatValue] < 0) {
            self.priceNetChange.textColor = [UIColor redColor];
        } else {
            self.priceNetChange.textColor = [UIColor greenColor];
        }
        self.priceNetChange.text = netChange;
        
        if ([persentChange floatValue] < 0) {
            self.pricePercentChange.textColor = [UIColor redColor];
        } else {
            self.pricePercentChange.textColor = [UIColor greenColor];
        }
        if (persentChange) {
            self.pricePercentChange.text = [NSString stringWithFormat:@"%@%%", persentChange];
        }
    } else {
        if ([netChange floatValue] < 0) {
            self.priceNetChange.textColor = [UIColor redColor];
        } else {
            self.priceNetChange.textColor = [UIColor greenColor];
        }
        if (persentChange) {
            self.priceNetChange.text = [NSString stringWithFormat:@"%@ (%@%%)", netChange, persentChange];
        }
    }
}

- (void)setChartTypeTo:(NSString *)type
{
    if ([type isEqualToString:NSLocalizedString(@"Bar", nil)]) {
        chartType = ChartTypeBar;
    } else if ([type isEqualToString:NSLocalizedString(@"Candle", nil)]) {
        chartType = ChartTypeCandle;
    } else if ([type isEqualToString:NSLocalizedString(@"Line", nil)]) {
        chartType = ChartTypeLine;
    } else if ([type isEqualToString:NSLocalizedString(@"Area", nil)]) {
        chartType = ChartTypeArea;
    }
}

#pragma mark - Synthesize

@synthesize currentPrice;
@synthesize pricePercentChange;
@synthesize priceNetChange;
@synthesize bidPrice;
@synthesize bidSize;
@synthesize askPrice;
@synthesize askSize;
@synthesize openPrice;
@synthesize highPrice;
@synthesize lowPrice;
@synthesize volumeValue;
@synthesize prevClosePrice;

@synthesize bidSlashSizeLabel;
@synthesize askSlashSizeLabel;
@synthesize openLabel;
@synthesize volumeLabel;
@synthesize highLabel;
@synthesize prevCloseLabel;
@synthesize dollarVolumeLabel;
@synthesize lowLabel;

@synthesize movingView;
@synthesize plotView;
@synthesize newsView;
@synthesize optionsView;

@synthesize chartButton;
@synthesize newsButton;
@synthesize optionsButton;

@synthesize currentSymbol;
@synthesize quoteChartLeftButton, quoteChartCenterButton, quoteChartRightButton;

@synthesize blackLabel;
@synthesize borderLabel;
@synthesize plotShowButton;
@synthesize plotHideButton;
@synthesize plotDrawingAreaView;
@synthesize setupChartButton;

@synthesize titleView;
@synthesize titleShortName;
@synthesize titleLongName;

@synthesize arrayOfCandlesticks;

- (void)viewDidUnload {
    [self setVolumeValue:nil];
    [self setPrevClosePrice:nil];
    [super viewDidUnload];
}
@end
