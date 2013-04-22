//
//  ChartSetupViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 10/17/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ChartSetupViewController.h"
#import "HorizontalPicker.h"
#import "SelectStudyViewController.h"

typedef enum
{
    AggregationIntraday,
    AggregationDaily
} Aggregation;

@interface ChartSetupViewController()
{
    Aggregation aggregation;
    
    UIButton *studyThatWasPressed;
    // keys - @"first", @"second", @"third"
    NSMutableDictionary *studiesOptions;
    
    HorizontalPicker *typePicker;
    HorizontalPicker *periodPicker;
    HorizontalPicker *intervalPicker;
    
    NSString *barString;
    NSString *candleString;
    NSString *lineString;
    NSString *areaString;
    
    NSString *firslStudyName;
    NSString *secondStudyName;
    NSString *thirdStudyName;
}

@property (nonatomic, strong) NSMutableDictionary *studiesOptions;

@property (nonatomic, strong) HorizontalPicker *typePicker;
@property (nonatomic, strong) HorizontalPicker *periodPicker;
@property (nonatomic, strong) HorizontalPicker *intervalPicker;

@property (nonatomic, copy) NSString *barString;
@property (nonatomic, copy) NSString *candleString;
@property (nonatomic, copy) NSString *lineString;
@property (nonatomic, copy) NSString *areaString;

@property (nonatomic, copy) NSString *firslStudyName;
@property (nonatomic, copy) NSString *secondStudyName;
@property (nonatomic, copy) NSString *thirdStudyName;

- (void)localize;
- (void)loadStandartUserDefaults;
- (void)configureBarButtonItems;
- (void)createPickers;
- (NSArray *)arrayOfNSStringForPeriodPicker;
- (NSArray *)arrayOfNSStringForIntervalPicker;
- (void)setupSelectStudyButtons;
- (void)createBorderForButton:(UIButton *)button;
@end

@implementation ChartSetupViewController

@synthesize delegate;

@synthesize typeLabel;
@synthesize barsToRightLabel;
@synthesize aggregationLabel;
@synthesize periodLabel;
@synthesize intervalLabel;
@synthesize upperStudiesLabel;
@synthesize lowerStudiesLabel;
@synthesize selectStudyFirstLabel;
@synthesize selectStudySecondLabel;
@synthesize selectStudyThirdLabel;

@synthesize intradayButton;
@synthesize dailyButton;
@synthesize selectStudyFirstButton;
@synthesize selectStudySecondButton;
@synthesize selectStudyThirdButton;

@synthesize studiesOptions;

@synthesize barsToRightTextField;
@synthesize buttonForBarsToRightTextField;

@synthesize typeImageView;
@synthesize periodImageView;
@synthesize intervalImageView;

@synthesize resetChartSettingsButton;

@synthesize typePicker, periodPicker, intervalPicker;

@synthesize barString, candleString, lineString, areaString;
@synthesize firslStudyName, secondStudyName, thirdStudyName;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    [self loadStandartUserDefaults];
    [self configureBarButtonItems];
    [self createPickers];
    [self setupSelectStudyButtons];
}

#pragma mark - Buttons

- (void)doneButtonPressed
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 self.firslStudyName, @"first",
                                 self.secondStudyName, @"second",
                                 self.thirdStudyName, @"lowerStudy",
                                 self.selectStudyFirstLabel.text, @"firstLabel",
                                 self.selectStudySecondLabel.text, @"secondLabel",
                                 self.selectStudyThirdLabel.text, @"lowerStudyLabel",
                                 nil];
    
    if ([self.studiesOptions objectForKey:@"first"]) {
        [dict setObject:[self.studiesOptions objectForKey:@"first"] forKey:@"firstOptions"];
    }
    if ([self.studiesOptions objectForKey:@"second"]) {
        [dict setObject:[self.studiesOptions objectForKey:@"second"] forKey:@"secondOptions"];
    }
    if ([self.studiesOptions objectForKey:@"third"]) {
        [dict setObject:[self.studiesOptions objectForKey:@"third"] forKey:@"lowerStudyOptions"];
    }
    [standartUserDefaults setObject:dict forKey:@"studyButtons"];
    
    [self.barsToRightTextField resignFirstResponder];
    
    NSString *aggregationString = @"daily";
    if (aggregation == AggregationIntraday) {
        aggregationString = @"intraday";
    }
    
    NSDictionary *chartOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self.typePicker selectedString], @"type",
                                  self.barsToRightTextField.text, @"barsToRight",
                                  aggregationString, @"aggregation",
                                  [self.periodPicker selectedString], @"period",
                                  [self.intervalPicker selectedString], @"interval",
                                  nil];
    
    [standartUserDefaults setObject:chartOptions forKey:@"chartOptions"];
    
    [standartUserDefaults synchronize];

    if ([self.delegate respondsToSelector:@selector(chartSetupViewControllerhasChangedUserDefaults:)]) {
        [self.delegate chartSetupViewControllerhasChangedUserDefaults:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)intradayOrDailyButtonPresser:(id)sender
{
    if ([sender isEqual:self.dailyButton]) {
        self.dailyButton.enabled = NO;
        self.intradayButton.enabled = YES;
        aggregation = AggregationDaily;
    } else if ([sender isEqual:self.intradayButton]) {
        self.dailyButton.enabled = YES;
        self.intradayButton.enabled = NO;
        aggregation = AggregationIntraday;
    }
    [self.typePicker.scrollView removeFromSuperview];
    [self.periodPicker.scrollView removeFromSuperview];
    [self.intervalPicker.scrollView removeFromSuperview];
    self.typePicker = nil;
    self.periodPicker = nil;
    self.intervalPicker = nil;
    [self createPickers];
}

- (IBAction)selectStudyButtonPressed:(UIButton *)sender
{
    studyThatWasPressed = sender;
    
    NSString *senderName;
    if ([studyThatWasPressed isEqual:self.selectStudyFirstButton]) {
        senderName = self.firslStudyName;
    } else if ([studyThatWasPressed isEqual:self.selectStudySecondButton]) {
        senderName = self.secondStudyName;
    } else if ([studyThatWasPressed isEqual:self.selectStudyThirdButton]) {
        senderName = self.thirdStudyName;
    }
    
    if ([senderName isEqualToString:NSLocalizedString(@"Select study", nil)]) {
        senderName = NSLocalizedString(@"None", nil);
    }
    
    SelectStudyViewController *ssvc = [[SelectStudyViewController alloc] init];
    ssvc.delegate = self;
    ssvc.cellNameToSelect = senderName;
    
    if ([sender isEqual:self.selectStudyFirstButton] || [sender isEqual:self.selectStudySecondButton]) {
        
        ssvc.title = NSLocalizedString(@"Upper Studies", nil);
        ssvc.arrayOfStudies = [NSArray arrayWithObjects:
                               NSLocalizedString(@"None", nil), 
                               NSLocalizedString(@"Simple Moving Average (MA)", nil),
                               NSLocalizedString(@"Exponential Moving Average (EMA)", nil),
                               NSLocalizedString(@"Bollinger Bands", nil),
                               nil];

        if ([sender isEqual:self.selectStudyFirstButton]) {
            ssvc.optionsForCellToSelect = [self.studiesOptions objectForKey:@"first"];
        } else {
            ssvc.optionsForCellToSelect = [self.studiesOptions objectForKey:@"second"];
        }
        
    } else if ([sender isEqual:self.selectStudyThirdButton]) {
        ssvc.title = NSLocalizedString(@"Lower Studies", nil);
        ssvc.arrayOfStudies = [NSArray arrayWithObjects:
                               NSLocalizedString(@"None", nil),
                               NSLocalizedString(@"MACD", nil),
                               NSLocalizedString(@"RSI", nil),
                               NSLocalizedString(@"Stochastics", nil),
                               nil];
        ssvc.optionsForCellToSelect = [self.studiesOptions objectForKey:@"third"];
    }
    
    [self.navigationController pushViewController:ssvc animated:YES];
}

- (IBAction)resetChartSettingsButtonPressed:(id)sender
{
    self.barsToRightTextField.text = @"3";
    
    [self intradayOrDailyButtonPresser:self.intradayButton];
    [self.typePicker selectObjectNamed:self.barString];
    [self.intervalPicker selectObjectNamed:@"5 Min"];
    
    self.selectStudyFirstLabel.text = NSLocalizedString(@"Select study", nil);
    self.selectStudySecondLabel.text = NSLocalizedString(@"Select study", nil);
    self.selectStudyThirdLabel.text = NSLocalizedString(@"Select study", nil);
    self.firslStudyName = NSLocalizedString(@"Select study", nil);
    self.secondStudyName = NSLocalizedString(@"Select study", nil);
    self.thirdStudyName = NSLocalizedString(@"Select study", nil);    
}

- (IBAction)backgroundTouch:(id)sender
{
    [self.barsToRightTextField resignFirstResponder];
}

#pragma mark - Horizontal picker delegate

- (void)horisontalPicker:(HorizontalPicker *)picker hasSelected:(NSInteger)number
{
    
}

#pragma mark - SelectStudyViewController delegate

- (void)selectStudyViewController:(SelectStudyViewController *)controller didSelectRowWithName:(NSString *)name withOptions:(NSDictionary *)options
{
    NSString *newName = name;
    NSString *realName = name;
    if ([name isEqualToString:NSLocalizedString(@"None", nil)]) {
        newName = NSLocalizedString(@"Select study", nil);
        realName = NSLocalizedString(@"Select study", nil);
    }
    
    if (!studiesOptions) {
        studiesOptions = [[NSMutableDictionary alloc] init];
    }
    
    NSString *parametersString = nil;
    if (options) {
        parametersString = [options objectForKey:@"parametersString"];
    }
    
    if (parametersString) {
        CGSize parametersSize = [parametersString sizeWithFont:[UIFont systemFontOfSize:17]];
        CGSize nameSize = [newName sizeWithFont:[UIFont systemFontOfSize:17]];
        BOOL wasNameTruncated = NO;
        while ((parametersSize.width + nameSize.width) > 230) {
            wasNameTruncated = YES;
            if ([newName length] > 0 ) {
                newName = [newName substringToIndex:[newName length] - 1];
            } else {
                break;
            }
            
            nameSize = [newName sizeWithFont:[UIFont systemFontOfSize:17]];
            nameSize.width += [@"..." sizeWithFont:[UIFont systemFontOfSize:17]].width;
        }
        
        if (wasNameTruncated) {
            newName = [newName stringByAppendingFormat:@"..."];
        }
        newName = [newName stringByAppendingFormat:@" %@", parametersString];
    }
    
    if ([studyThatWasPressed isEqual:self.selectStudyFirstButton]) {
        self.selectStudyFirstLabel.text = newName;
        self.firslStudyName = realName;
        if (options)
            [self.studiesOptions setObject:options forKey:@"first"];
        
    } else if ([studyThatWasPressed isEqual:self.selectStudySecondButton]) {
        self.selectStudySecondLabel.text = newName;
        self.secondStudyName = realName;
        if (options)
            [self.studiesOptions setObject:options forKey:@"second"];
        
    } else if ([studyThatWasPressed isEqual:self.selectStudyThirdButton]) {
        self.selectStudyThirdLabel.text = newName;
        self.thirdStudyName = realName;
        if (options)
            [self.studiesOptions setObject:options forKey:@"third"];
    }
}

#pragma mark - Text Field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.barsToRightTextField]) {
        self.buttonForBarsToRightTextField.hidden = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.barsToRightTextField]) {
        self.buttonForBarsToRightTextField.hidden = YES;

        while (([textField.text length] > 1) && ([textField.text characterAtIndex:0] == '0')) {
            textField.text = [textField.text substringFromIndex:1];
        }
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"0";
        } else if ([textField.text integerValue] > 20) {
            textField.text = @"20";
        }
    }
    return YES;
}

#pragma mark - Supporting methods

- (void)localize
{
    self.title = NSLocalizedString(@"Charting Setup", nil);
    self.barsToRightLabel.text = NSLocalizedString(@"Bars to right", nil);
    self.typeLabel.text = NSLocalizedString(@"Type", nil);
    self.aggregationLabel.text = NSLocalizedString(@"Aggregation", nil);
    self.periodLabel.text = NSLocalizedString(@"Period", nil);
    self.intervalLabel.text = NSLocalizedString(@"Interval", nil);
    self.upperStudiesLabel.text = NSLocalizedString(@"Upper Studies", nil);
    self.lowerStudiesLabel.text = NSLocalizedString(@"Lower Studies", nil);
    
    [self.intradayButton setTitle:NSLocalizedString(@"Intraday", nil) forState:UIControlStateNormal];
    [self.dailyButton setTitle:NSLocalizedString(@"Daily", nil) forState:UIControlStateNormal];

    
    self.barString = NSLocalizedString(@"Bar", nil);
    self.candleString = NSLocalizedString(@"Candle", nil);
    self.lineString = NSLocalizedString(@"Line", nil);
    self.areaString = NSLocalizedString(@"Area", nil);
    
    [self.resetChartSettingsButton setTitle:NSLocalizedString(@"Reset Chart Settings", nil) forState:UIControlStateNormal];
}

- (void)loadStandartUserDefaults
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.barsToRightTextField.text = [[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"barsToRight"];
    if (!self.barsToRightTextField.text) {
        self.barsToRightTextField.text = @"3";
    }
    
    NSString *aggregationString = [[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"aggregation"];
    aggregation = AggregationIntraday;
    if ([aggregationString isEqualToString:@"daily"]) {
        aggregation = AggregationDaily;
        self.dailyButton.enabled = NO;
        self.intradayButton.enabled = YES;
    }
    
    NSDictionary *studyButtons = [standartUserDefaults objectForKey:@"studyButtons"];
    if (studyButtons) {
        self.selectStudyFirstLabel.text = [studyButtons objectForKey:@"firstLabel"];
        self.selectStudySecondLabel.text = [studyButtons objectForKey:@"secondLabel"];
        self.selectStudyThirdLabel.text = [studyButtons objectForKey:@"lowerStudyLabel"];
        self.firslStudyName = [studyButtons objectForKey:@"first"];
        self.secondStudyName = [studyButtons objectForKey:@"second"];
        self.thirdStudyName = [studyButtons objectForKey:@"lowerStudy"];
        
        studiesOptions = [[NSMutableDictionary alloc] init];
        if ([studyButtons objectForKey:@"firstOptions"]) {
            [self.studiesOptions setObject:[studyButtons objectForKey:@"firstOptions"] 
                                    forKey:@"first"];
        }
        if ([studyButtons objectForKey:@"secondOptions"]) {
            [self.studiesOptions setObject:[studyButtons objectForKey:@"secondOptions"] 
                                    forKey:@"second"];
        }
        if ([studyButtons objectForKey:@"lowerStudyOptions"]) {
            [self.studiesOptions setObject:[studyButtons objectForKey:@"lowerStudyOptions"] 
                                    forKey:@"third"];
        }
    } else {
        self.selectStudyFirstLabel.text = NSLocalizedString(@"Select study", nil);
        self.selectStudySecondLabel.text = NSLocalizedString(@"Select study", nil);
        self.selectStudyThirdLabel.text = NSLocalizedString(@"Select study", nil);
        self.firslStudyName = NSLocalizedString(@"Select study", nil);
        self.secondStudyName = NSLocalizedString(@"Select study", nil);
        self.thirdStudyName = NSLocalizedString(@"Select study", nil);    
    }
}


- (void)configureBarButtonItems
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                target:self
                                                                                action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)createPickers
{
    self.typePicker = [[HorizontalPicker alloc] initWithArrayOfNSString:[NSArray arrayWithObjects:
                                                                         self.barString,
                                                                         self.candleString,
                                                                         self.lineString,
                                                                         self.areaString, nil]
                                                               andFrame:self.typeImageView.frame
                                                                 cycled:YES];
    [self.view addSubview:self.typePicker.scrollView];
    self.typePicker.delegate = self;
    
    self.periodPicker = [[HorizontalPicker alloc] initWithArrayOfNSString:[self arrayOfNSStringForPeriodPicker]
                                                                 andFrame:self.periodImageView.frame];
    [self.view addSubview:self.periodPicker.scrollView];
    self.periodPicker.delegate = self;
    
    self.intervalPicker = [[HorizontalPicker alloc] initWithArrayOfNSString:[self arrayOfNSStringForIntervalPicker]
                                                                   andFrame:self.intervalImageView.frame];
    [self.view addSubview:self.intervalPicker.scrollView];
    self.intervalPicker.delegate = self;
    
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *typeString = [[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"type"];
    NSString *periodString = [[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"period"];
    NSString *intervalString = [[standartUserDefaults objectForKey:@"chartOptions"] objectForKey:@"interval"];
    
    if (typeString) {
        [self.typePicker selectObjectNamed:typeString];
    }
    if (periodString) {
        [self.periodPicker selectObjectNamed:periodString];
    }
    if (intervalString) {
        [self.intervalPicker selectObjectNamed:intervalString];
    } else {
        [self.intervalPicker selectObjectNamed:@"5 Min"];
    }
}

- (NSArray *)arrayOfNSStringForPeriodPicker
{
    NSArray *arrayToReturn;
    if (aggregation == AggregationIntraday) {
        arrayToReturn = [NSArray arrayWithObjects:@"1 Day", @"3 Days", @"5 days", nil];
    } else {
        arrayToReturn = [NSArray arrayWithObjects:@"1 Month", @"3 Months", @"6 Months", @"1 Year", @"2 Years", @"5 Years", nil];
    }
    return arrayToReturn;
}

- (NSArray *)arrayOfNSStringForIntervalPicker
{
    NSArray *arrayToReturn;
    if (aggregation == AggregationIntraday) {
        arrayToReturn = [NSArray arrayWithObjects:@"1 Min", @"5 Min", @"15 Min", @"30 Min", @"1 hr", nil];
    } else {
        arrayToReturn = [NSArray arrayWithObjects:@"1 Day", @"1 Week", @"1 Month", nil];
    }
    return arrayToReturn;
}

- (void)setupSelectStudyButtons
{
    [self createBorderForButton:self.selectStudyFirstButton];
    [self createBorderForButton:self.selectStudySecondButton];
    [self createBorderForButton:self.selectStudyThirdButton];
}

- (void)createBorderForButton:(UIButton *)button
{
    button.layer.cornerRadius = 10;
    button.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    button.layer.borderWidth = 1;
}

@end
