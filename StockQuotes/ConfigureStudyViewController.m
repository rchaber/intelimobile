//
//  ConfigureStudyViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 10/21/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "ConfigureStudyViewController.h"
#import "ConfigureStudyCell.h"
#import "ConfigureStudyValueCell.h"
#import "ConfigureStudyButtonCell.h"
#import "ConfigureStudyColorCell.h"

@interface ConfigureStudyViewController()
{
    NSString *nameOfPlot;
    NSMutableArray *arrayOfCells;
    
    UITextField *__unsafe_unretained selectedTextField;
    UIButton *buttonForDisabelingTextField;
}
@property (nonatomic, copy) NSString *nameOfPlot;
@property (nonatomic, strong) NSMutableArray *arrayOfCells;

@property (nonatomic, unsafe_unretained) UITextField *selectedTextField;
@property (nonatomic, strong) UIButton *buttonForDisabelingTextField;

- (void)buttonForDisabelingTextFieldPressed;
- (void)createArrayOfCells;
- (UITableViewCell *)cellForSimpleMovingAverageForCellAtIndex:(NSInteger)index;
- (UITableViewCell *)cellForBollingerBandsForCellAtIndex:(NSInteger)index;
- (UITableViewCell *)cellForMACDForCellAtIndex:(NSInteger)index;
- (UITableViewCell *)cellForRSIForCellAtIndex:(NSInteger)index;
- (UITableViewCell *)cellForStochasticsForCellAtIndex:(NSInteger)index;

- (ConfigureStudyCell *)valueCellWithText:(NSString *)text 
                                  minimum:(CGFloat)min
                                  maximum:(CGFloat)max
                                    delta:(CGFloat)delta
                             currentValue:(CGFloat)curVal;
- (ConfigureStudyCell *)buttonCellWithText:(NSString *)text
                                    titles:(NSArray *)titles;
- (ConfigureStudyCell *)colorCellWithText:(NSString *)text;

- (NSDictionary *)parametersForSimpleMovingAverage;
- (NSDictionary *)parametersForExponentialMovingAverage;
- (NSDictionary *)parametersForBollingerBands;
- (NSDictionary *)parametersForMACD;
- (NSDictionary *)parametersForRSI;
- (NSDictionary *)parametersForStochastics;

- (NSString *)valueStringOfValueCellAtIndex:(NSInteger)index;
- (NSString *)titleOfButtonStringAtIndex:(NSInteger)index;
- (UIColor *)colorOfColorCellAtIndex:(NSInteger)index;

- (NSString *)substituteHighLowToMaxMinInString:(NSString *)string;
- (UIColor *)colorFromDict:(NSDictionary *)colorDict;
@end

@implementation ConfigureStudyViewController

#pragma mark - Livecycle

- (id)initWithNameOfPlot:(NSString *)name andOptions:(NSDictionary *)options
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.oldOptions = options;
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.separatorColor = [UIColor darkGrayColor];
        self.nameOfPlot = name;
        self.title = name;
        
        [self createArrayOfCells];
        
        UITableView *tView = self.tableView;
        UIView *newView = [[UIView alloc] initWithFrame:self.tableView.frame];
        self.view = newView;
        
        [self.view addSubview:tView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(doneButtonPressed)];
    self.navigationItem.leftBarButtonItem = doneButton;

    self.buttonForDisabelingTextField = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonForDisabelingTextField.frame = CGRectMake(self.view.frame.origin.x,
                                                         self.view.frame.origin.y,
                                                         self.view.frame.size.width,
                                                         self.view.frame.size.height);

    self.buttonForDisabelingTextField.backgroundColor = [UIColor clearColor];
    [self.buttonForDisabelingTextField addTarget:self action:@selector(buttonForDisabelingTextFieldPressed) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:self.buttonForDisabelingTextField];
    self.buttonForDisabelingTextField.hidden = YES;
}

- (void)viewDidUnload
{
    self.nameOfPlot = nil;
    self.arrayOfCells = nil;
    self.buttonForDisabelingTextField = nil;
}


#pragma mark - Buttons

- (void)doneButtonPressed
{
    NSDictionary *parameters = nil;
    
    if ([self.nameOfPlot isEqualToString:NSLocalizedString(@"Simple Moving Average (MA)", nil)]) {
        parameters = [self parametersForSimpleMovingAverage];
        
    } else if ([self.nameOfPlot isEqualToString:NSLocalizedString(@"Exponential Moving Average (EMA)", nil)]) {
        parameters = [self parametersForExponentialMovingAverage];
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"Bollinger Bands", nil)]) {
        parameters = [self parametersForBollingerBands];
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"MACD", nil)]) {
        parameters = [self parametersForMACD];
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"RSI", nil)]) {
        parameters = [self parametersForRSI];
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"Stochastics", nil)]) {
        parameters = [self parametersForStochastics];
        
    }
    if ([delegate respondsToSelector:@selector(configureStudyViewControllerpopedUpForName:withParameters:)]) {
        [delegate configureStudyViewControllerpopedUpForName:self.nameOfPlot withParameters:parameters];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayOfCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.arrayOfCells objectAtIndex:indexPath.row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - ConfigureStudyValueCell delegate

- (void)configureStudyValueCell:(ConfigureStudyValueCell *)cell wasPressedTextField:(UITextField *)textField
{
    self.selectedTextField = textField;
    self.buttonForDisabelingTextField.hidden = NO;
}

- (void)configureStudyValueCell:(ConfigureStudyValueCell *)cell endEditingTextField:(UITextField *)textField
{
    self.selectedTextField = nil;
    self.buttonForDisabelingTextField.hidden = YES;
}

#pragma mark - Supporting methods

- (void)buttonForDisabelingTextFieldPressed
{
    [self.selectedTextField resignFirstResponder];
}

- (void)createArrayOfCells
{
    self.arrayOfCells = [NSMutableArray array];
    if ([nameOfPlot isEqualToString:NSLocalizedString(@"Simple Moving Average (MA)", nil)]) {
        for (int i = 0; i < 3; i++) {
            [self.arrayOfCells addObject:[self cellForSimpleMovingAverageForCellAtIndex:i]];
        }
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"Exponential Moving Average (EMA)", nil)]) {
        for (int i = 0; i < 3; i++) {
            // it is same
            [self.arrayOfCells addObject:[self cellForSimpleMovingAverageForCellAtIndex:i]];
        }
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"Bollinger Bands", nil)]) {
        for (int i = 0; i < 5; i++) {
            [self.arrayOfCells addObject:[self cellForBollingerBandsForCellAtIndex:i]];
        }
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"MACD", nil)]) {
        for (int i = 0; i < 7; i++) {
            [self.arrayOfCells addObject:[self cellForMACDForCellAtIndex:i]];
        }
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"RSI", nil)]) {
        for (int i = 0; i < 5; i++) {
            [self.arrayOfCells addObject:[self cellForRSIForCellAtIndex:i]];
        }
        
    } else if ([nameOfPlot isEqualToString:NSLocalizedString(@"Stochastics", nil)]) {
        for (int i = 0; i < 11; i++) {
            [self.arrayOfCells addObject:[self cellForStochasticsForCellAtIndex:i]];
        }
        
    }
}

- (UITableViewCell *)cellForSimpleMovingAverageForCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = nil;
    if (index == 0) {
        cell = [self valueCellWithText:NSLocalizedString(@"Length", NULL)
                               minimum:1 
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:9];
    } 
    else if (index == 1) {
        cell = [self buttonCellWithText:NSLocalizedString(@"Price", NULL)
                                 titles:[NSArray arrayWithObjects:
                                         NSLocalizedString(@"Close", NULL),
                                         NSLocalizedString(@"High", NULL),
                                         NSLocalizedString(@"Low", NULL),
                                         NSLocalizedString(@"Open", NULL),
                                         nil]];
    } 
    else if (index == 2) {
        cell = [self colorCellWithText:NSLocalizedString(@"Color", NULL)];
    }
    
    if (self.oldOptions) {
        if (index == 0) {
            float value = [[self.oldOptions objectForKey:@"length"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 1) {
            NSString *string = [self.oldOptions objectForKey:@"price"];
            if ([string caseInsensitiveCompare:NSLocalizedString(@"Close", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"max"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
            else if ([string caseInsensitiveCompare:@"min"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:2];
            } 
            else if ([string caseInsensitiveCompare:NSLocalizedString(@"Open", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:3];
            } 
        }
        else if (index == 2) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"color"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
    }
    return cell;
}

- (UITableViewCell *)cellForBollingerBandsForCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = nil;
    if (index == 0) {
        cell = [self valueCellWithText:NSLocalizedString(@"Length", NULL) 
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:9];
    } else if (index == 1) {
        cell = [self valueCellWithText:NSLocalizedString(@"NumDevDn", NULL)
                               minimum:INT_MIN 
                               maximum:0
                                 delta:0.02
                          currentValue:-2];
    } else if (index == 2) {
        cell = [self valueCellWithText:NSLocalizedString(@"NumDevUp", NULL)
                               minimum:0 
                               maximum:MAXFLOAT
                                 delta:0.02
                          currentValue:2];
    } else if (index == 3) {
        cell = [self buttonCellWithText:NSLocalizedString(@"Price", NULL)
                                 titles:[NSArray arrayWithObjects:
                                         NSLocalizedString(@"Close", NULL),
                                         NSLocalizedString(@"High", NULL),
                                         NSLocalizedString(@"Low", NULL),
                                         NSLocalizedString(@"Open", NULL),
                                         nil]];
    } else if (index == 4) {
        cell = [self colorCellWithText:NSLocalizedString(@"Color", NULL)];
    }
    
    if (self.oldOptions) {
        if (index == 0) {
            float value = [[self.oldOptions objectForKey:@"length"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        }
        else if (index == 1) {
            float value = [[self.oldOptions objectForKey:@"numDevDn"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        }
        else if (index == 2) {
            float value = [[self.oldOptions objectForKey:@"numDevUp"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        }
        else if (index == 3) {
            NSString *string = [self.oldOptions objectForKey:@"price"];
            if ([string caseInsensitiveCompare:NSLocalizedString(@"Close", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"max"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
            else if ([string caseInsensitiveCompare:@"min"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:2];
            } 
            else if ([string caseInsensitiveCompare:NSLocalizedString(@"Open", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:3];
            } 
        }
        else if (index == 4) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"color"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
    }
    
    return cell;
}

- (UITableViewCell *)cellForMACDForCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = nil;
    if (index == 0) {
        cell = [self valueCellWithText:NSLocalizedString(@"MACDLength", NULL)
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:9];
    } else if (index == 1) {
        cell = [self buttonCellWithText:NSLocalizedString(@"AverageType", NULL) 
                                 titles:[NSArray arrayWithObjects:
                                         NSLocalizedString(@"SMA", NULL),
                                         NSLocalizedString(@"EMA", NULL),
                                         nil]];
    } else if (index == 2) {
        cell = [self valueCellWithText:NSLocalizedString(@"FastLength", NULL)
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:12];
    } else if (index == 3) {
        cell = [self valueCellWithText:NSLocalizedString(@"SlowLength", NULL) 
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:26];
    } else if (index == 4) {
        cell = [self colorCellWithText:NSLocalizedString(@"MACD", NULL)];
    } else if (index == 5) {
        cell = [self colorCellWithText:NSLocalizedString(@"Signal Line", NULL)];
    } else if (index == 6) {
        cell = [self colorCellWithText:NSLocalizedString(@"Histogram", NULL)];
    }
    
    if (self.oldOptions) {
        if (index == 0) {
            float value = [[self.oldOptions objectForKey:@"MACDLength"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 1) {
            NSString *string = [self.oldOptions objectForKey:@"averageType"];
            if ([string caseInsensitiveCompare:@"sma"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"ema"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
        }
        else if (index == 2) {
            float value = [[self.oldOptions objectForKey:@"fastLength"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 3) {
            float value = [[self.oldOptions objectForKey:@"slowLength"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 4) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"macdColor"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
        else if (index == 5) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"signalLineColor"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
        else if (index == 6) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"histogramColor"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
    }
    
    return cell;
}

- (UITableViewCell *)cellForRSIForCellAtIndex:(NSInteger)index
{
    UITableViewCell *cell = nil;
    if (index == 0) {
        cell = [self valueCellWithText:NSLocalizedString(@"Length", NULL)
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:14];
    } else if (index == 1) {
        cell = [self valueCellWithText:NSLocalizedString(@"OverBought", NULL) 
                               minimum:0 
                               maximum:100
                                 delta:1
                          currentValue:70];
    } else if (index == 2) {
        cell = [self valueCellWithText:NSLocalizedString(@"OverSold", NULL)
                               minimum:0 
                               maximum:100 
                                 delta:1
                          currentValue:30];
    } else if (index == 3) {
        cell = [self buttonCellWithText:NSLocalizedString(@"Price", NULL)
                                 titles:[NSArray arrayWithObjects:
                                         NSLocalizedString(@"Close", NULL),
                                         NSLocalizedString(@"High", NULL),
                                         NSLocalizedString(@"Low", NULL),
                                         NSLocalizedString(@"Open", NULL),
                                         nil]];
    } else if (index == 4) {
        cell = [self colorCellWithText:NSLocalizedString(@"Color", NULL)];
    }
    
    if (self.oldOptions) {
        if (index == 0) {
            float value = [[self.oldOptions objectForKey:@"length"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 1) {
            float value = [[self.oldOptions objectForKey:@"overBought"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 2) {
            float value = [[self.oldOptions objectForKey:@"overSold"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 3) {
            NSString *string = [self.oldOptions objectForKey:@"price"];
            if ([string caseInsensitiveCompare:NSLocalizedString(@"Close", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"max"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
            else if ([string caseInsensitiveCompare:@"min"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:2];
            } 
            else if ([string caseInsensitiveCompare:NSLocalizedString(@"Open", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:3];
            } 
        }
        else if (index == 4) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"color"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
    }
    
    return cell;
}

- (UITableViewCell *)cellForStochasticsForCellAtIndex:(NSInteger)index
{
    NSArray *arrayWithTitles = [NSArray arrayWithObjects:
                                NSLocalizedString(@"Close", NULL),
                                NSLocalizedString(@"High", NULL),
                                NSLocalizedString(@"Low", NULL),
                                NSLocalizedString(@"Open", NULL),
                                nil];
    
    UITableViewCell *cell = nil;
    if (index == 0) {
        cell = [self valueCellWithText:NSLocalizedString(@"DPeriod", NULL)
                               minimum:1
                               maximum:MAXFLOAT 
                                 delta:1
                          currentValue:10];
    } else if (index == 1) {
        cell = [self valueCellWithText:NSLocalizedString(@"KPeriod", NULL)
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:10];
    } else if (index == 2) {
        cell = [self valueCellWithText:NSLocalizedString(@"OverBought", NULL)
                               minimum:0
                               maximum:100
                                 delta:1
                          currentValue:80];
    } else if (index == 3) {
        cell = [self valueCellWithText:NSLocalizedString(@"OverSold", NULL)
                               minimum:0
                               maximum:100
                                 delta:1
                          currentValue:20];
    } else if (index == 4) {
        cell = [self buttonCellWithText:NSLocalizedString(@"PriceC", NULL)
                                 titles:arrayWithTitles];
    } else if (index == 5) {
        cell = [self buttonCellWithText:NSLocalizedString(@"PriceH", NULL)
                                 titles:arrayWithTitles];
    } else if (index == 6) {
        cell = [self buttonCellWithText:NSLocalizedString(@"PriceL", NULL)
                                 titles:arrayWithTitles];
    } else if (index == 7) {
        cell = [self valueCellWithText:NSLocalizedString(@"SlowingPeriod", NULL)
                               minimum:1
                               maximum:MAXFLOAT
                                 delta:1
                          currentValue:3];
    } else if (index == 8) {
        cell = [self buttonCellWithText:NSLocalizedString(@"SmoothingType", NULL)
                                 titles:[NSArray arrayWithObjects:
                                         NSLocalizedString(@"SMA", NULL),
                                         NSLocalizedString(@"EMA", NULL),
                                         nil]];
    } else if (index == 9) {
        cell = [self colorCellWithText:NSLocalizedString(@"Full %K", NULL)];
    } else if (index == 10) {
        cell = [self colorCellWithText:NSLocalizedString(@"Full %D", NULL)];
    }
    
    if (self.oldOptions) {
        if (index == 0) {
            float value = [[self.oldOptions objectForKey:@"DPeriod"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 1) {
            float value = [[self.oldOptions objectForKey:@"KPeriod"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } else if (index == 2) {
            float value = [[self.oldOptions objectForKey:@"overBought"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 3) {
            float value = [[self.oldOptions objectForKey:@"overSold"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 4) {
            NSString *string = [self.oldOptions objectForKey:@"priceC"];
            if ([string caseInsensitiveCompare:NSLocalizedString(@"Close", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"max"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
            else if ([string caseInsensitiveCompare:@"min"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:2];
            } 
            else if ([string caseInsensitiveCompare:NSLocalizedString(@"Open", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:3];
            } 
        }
        else if (index == 5) {
            NSString *string = [self.oldOptions objectForKey:@"priceH"];
            if ([string caseInsensitiveCompare:NSLocalizedString(@"Close", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"max"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
            else if ([string caseInsensitiveCompare:@"min"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:2];
            } 
            else if ([string caseInsensitiveCompare:NSLocalizedString(@"Open", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:3];
            } 
        }
        else if (index == 6) {
            NSString *string = [self.oldOptions objectForKey:@"priceL"];
            if ([string caseInsensitiveCompare:NSLocalizedString(@"Close", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"max"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            } 
            else if ([string caseInsensitiveCompare:@"min"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:2];
            } 
            else if ([string caseInsensitiveCompare:NSLocalizedString(@"Open", NULL)] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:3];
            } 
        }
        else if (index == 7) {
            float value = [[self.oldOptions objectForKey:@"slowingPeriod"] floatValue];
            [(ConfigureStudyValueCell *)cell setCurrentValue:value];
        } 
        else if (index == 8) {
            NSString *string = [self.oldOptions objectForKey:@"smoothingType"];
            if ([string caseInsensitiveCompare:@"sma"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:0];
            } 
            else if ([string caseInsensitiveCompare:@"ema"] == NSOrderedSame) {
                [(ConfigureStudyButtonCell *)cell setTitleAtIndex:1];
            }
        }
        else if (index == 9) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"fullKColor"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
        else if (index == 10) {
            NSDictionary *colorDict = [[self.oldOptions objectForKey:@"color"] objectForKey:@"fullDColor"];
            [(ConfigureStudyColorCell *)cell setColorTo:[self colorFromDict:colorDict]];
        }
    }
    
    return cell;
}

- (ConfigureStudyCell *)valueCellWithText:(NSString *)text 
                                  minimum:(CGFloat)min
                                  maximum:(CGFloat)max
                                    delta:(CGFloat)delta
                             currentValue:(CGFloat)curVal
{
    [[NSBundle mainBundle] loadNibNamed:@"ConfigureStudyValueCell" owner:self options:nil];
    ConfigureStudyValueCell *cell = configureStudyValueCell;
    self.configureStudyValueCell = nil;
    cell.delegate = self;
    [cell setLabelTextTo:text];
    [cell setMinimumValue:min andMaximumValue:max];
    [cell setCurrentValue:curVal];
    [cell setDelta:delta];
    return cell;
}

- (ConfigureStudyCell *)buttonCellWithText:(NSString *)text
                                    titles:(NSArray *)titles
{
    [[NSBundle mainBundle] loadNibNamed:@"ConfigureStudyButtonCell" owner:self options:nil];
    ConfigureStudyButtonCell *cell = configureStudyButtonCell;
    self.configureStudyButtonCell = nil;

    [cell setLabelTextTo:text];
    cell.titles = titles;
    return cell;
}

- (ConfigureStudyCell *)colorCellWithText:(NSString *)text
{
    [[NSBundle mainBundle] loadNibNamed:@"ConfigureStudyColorCell" owner:self options:nil];
    ConfigureStudyCell *cell = configureStudyColorCell;
    self.configureStudyColorCell = nil;

    [cell setLabelTextTo:text];
    return cell;
}

#pragma mark - Parameters

- (NSDictionary *)parametersForSimpleMovingAverage
{
    NSDictionary *color = [NSDictionary dictionaryWithObject:[self colorOfColorCellAtIndex:2] forKey:@"color"];
    NSString *price = [self titleOfButtonStringAtIndex:1];
    
    NSString *parametersString = [NSString stringWithFormat:@"(%i)", 
                                  [[self valueStringOfValueCellAtIndex:0] integerValue]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self valueStringOfValueCellAtIndex:0], @"length",
            [self substituteHighLowToMaxMinInString:price], @"price",
            color, @"color",
            parametersString, @"parametersString",
            [@"MA " stringByAppendingString:parametersString], @"shortName",
            nil];
}

- (NSDictionary *)parametersForExponentialMovingAverage
{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:[self parametersForSimpleMovingAverage]];
    [param setObject:[@"E" stringByAppendingString:[param objectForKey:@"shortName"]]
              forKey:@"shortName"];
    return param;
}

- (NSDictionary *)parametersForBollingerBands
{
    NSDictionary *color = [NSDictionary dictionaryWithObject:[self colorOfColorCellAtIndex:4] forKey:@"color"];
    NSString *price = [self titleOfButtonStringAtIndex:3];
    
    NSString *parametersString = [NSString stringWithFormat:@"(%i,%.2g,%.2g)", 
                                  [[self valueStringOfValueCellAtIndex:0] integerValue],
                                  [[self valueStringOfValueCellAtIndex:1] floatValue],
                                  [[self valueStringOfValueCellAtIndex:2] floatValue]];
    
    NSString *shortName = [@"BB "stringByAppendingString:parametersString];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self valueStringOfValueCellAtIndex:0], @"length",
            [self valueStringOfValueCellAtIndex:1], @"numDevDn",
            [self valueStringOfValueCellAtIndex:2], @"numDevUp",
            [self substituteHighLowToMaxMinInString:price], @"price",
            color, @"color",
            parametersString, @"parametersString",
            shortName, @"shortName",
            nil];
}

- (NSDictionary *)parametersForMACD
{
    NSDictionary *color = [NSDictionary dictionaryWithObjectsAndKeys:
                           [self colorOfColorCellAtIndex:4], @"macdColor",
                           [self colorOfColorCellAtIndex:5], @"signalLineColor",
                           [self colorOfColorCellAtIndex:6], @"histogramColor",
                           nil];
    
    NSString *parametersString = [NSString stringWithFormat:@"(%i,%i,%i)", 
                                  [[self valueStringOfValueCellAtIndex:0] integerValue],
                                  [[self valueStringOfValueCellAtIndex:2] integerValue],
                                  [[self valueStringOfValueCellAtIndex:3] integerValue]];
    NSString *shortName = [@"MACD " stringByAppendingString:parametersString];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self valueStringOfValueCellAtIndex:0], @"MACDLength",
            [self titleOfButtonStringAtIndex:1], @"averageType",
            [self valueStringOfValueCellAtIndex:2], @"fastLength",
            [self valueStringOfValueCellAtIndex:3], @"slowLength",
            color, @"color",
            parametersString, @"parametersString",
            shortName, @"shortName",
            nil];
}

- (NSDictionary *)parametersForRSI
{
    NSDictionary *color = [NSDictionary dictionaryWithObject:[self colorOfColorCellAtIndex:4] forKey:@"color"];
    NSString *price = [self titleOfButtonStringAtIndex:3];
    
    NSString *parametersString = [NSString stringWithFormat:@"(%i,%i,%i)", 
                                  [[self valueStringOfValueCellAtIndex:0] integerValue],
                                  [[self valueStringOfValueCellAtIndex:1] integerValue],
                                  [[self valueStringOfValueCellAtIndex:2] integerValue]];
    
    NSString *shortName = [NSString stringWithFormat:@"RSI (%i)", [[self valueStringOfValueCellAtIndex:0] integerValue]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self valueStringOfValueCellAtIndex:0], @"length",
            [self valueStringOfValueCellAtIndex:1], @"overBought",
            [self valueStringOfValueCellAtIndex:2], @"overSold",
            [self substituteHighLowToMaxMinInString:price], @"price",
            color, @"color",
            parametersString, @"parametersString",
            shortName, @"shortName",
            nil];
}

- (NSDictionary *)parametersForStochastics
{
    NSDictionary *color = [NSDictionary dictionaryWithObjectsAndKeys:
                           [self colorOfColorCellAtIndex:9], @"fullKColor",
                           [self colorOfColorCellAtIndex:10], @"fullDColor",
                           nil];
    NSString *priceC = [self titleOfButtonStringAtIndex:4];
    NSString *priceH = [self titleOfButtonStringAtIndex:5];
    NSString *priceL = [self titleOfButtonStringAtIndex:6];
    
    NSString *parametersString = [NSString stringWithFormat:@"(%i,%i,%i,%i,%i)", 
                                  [[self valueStringOfValueCellAtIndex:0] integerValue],
                                  [[self valueStringOfValueCellAtIndex:1] integerValue],
                                  [[self valueStringOfValueCellAtIndex:2] integerValue],
                                  [[self valueStringOfValueCellAtIndex:3] integerValue],
                                  [[self valueStringOfValueCellAtIndex:7] integerValue]];
    NSString *shortName = [NSString stringWithFormat:@"St (%i,%i,%i)", 
                             [[self valueStringOfValueCellAtIndex:0] integerValue],
                             [[self valueStringOfValueCellAtIndex:1] integerValue],
                             [[self valueStringOfValueCellAtIndex:7] integerValue]];
                             
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
           [self valueStringOfValueCellAtIndex:0], @"DPeriod",
           [self valueStringOfValueCellAtIndex:1], @"KPeriod",
           [self valueStringOfValueCellAtIndex:2], @"overBought",
           [self valueStringOfValueCellAtIndex:3], @"overSold",
           [self substituteHighLowToMaxMinInString:priceC], @"priceC",
           [self substituteHighLowToMaxMinInString:priceH], @"priceH",
           [self substituteHighLowToMaxMinInString:priceL], @"priceL",
           [self valueStringOfValueCellAtIndex:7], @"slowingPeriod",
           [self titleOfButtonStringAtIndex:8], @"smoothingType",
           color, @"color",
           parametersString, @"parametersString",
           shortName, @"shortName",
           nil];
}

- (NSString *)valueStringOfValueCellAtIndex:(NSInteger)index
{
    ConfigureStudyValueCell *valueCell = [self.arrayOfCells objectAtIndex:index];
    return [NSString stringWithFormat:@"%f", [valueCell currentValue]];
}

- (NSString *)titleOfButtonStringAtIndex:(NSInteger)index
{
    return [[self.arrayOfCells objectAtIndex:index] currentTitle];
}

- (UIColor *)colorOfColorCellAtIndex:(NSInteger)index
{
    return [[self.arrayOfCells objectAtIndex:index] chosenColor];
}

- (NSString *)substituteHighLowToMaxMinInString:(NSString *)string
{
    if ([string isEqualToString:@"high"]) {
        string = @"max";
    } else if ([string isEqualToString:@"low"]) {
        string = @"min";
    }
    return string;
}

- (UIColor *)colorFromDict:(NSDictionary *)colorDict
{
    return [UIColor colorWithRed:[[colorDict objectForKey:@"red"] floatValue]
                           green:[[colorDict objectForKey:@"green"] floatValue]
                            blue:[[colorDict objectForKey:@"blue"] floatValue]
                           alpha:[[colorDict objectForKey:@"alpha"] floatValue]];
}

#pragma mark - Synthesize
                      
@synthesize configureStudyValueCell;
@synthesize configureStudyButtonCell;
@synthesize configureStudyColorCell;
@synthesize nameOfPlot;
@synthesize arrayOfCells;
@synthesize selectedTextField;
@synthesize buttonForDisabelingTextField;

@synthesize delegate;
@synthesize oldOptions = _oldOptions;

@end
