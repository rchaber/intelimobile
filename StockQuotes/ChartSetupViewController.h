//
//  ChartSetupViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 10/17/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalPicker.h"
#import "SelectStudyViewController.h"

typedef enum
{
    ChartTypeBar,
    ChartTypeCandle,
    ChartTypeLine,
    ChartTypeArea
} ChartType;

@class ChartSetupViewController;
@protocol ChartSetupViewControllerDelegate <NSObject>
@optional
- (void)chartSetupViewControllerhasChangedUserDefaults:(ChartSetupViewController *)controller;
@end

@interface ChartSetupViewController : UIViewController <HorizontalPickerDelegate, SelectStudyViewControllerDelegate, UITextFieldDelegate>
{
    id <ChartSetupViewControllerDelegate> __unsafe_unretained delegate;
    
    UILabel *typeLabel;
    UILabel *barsToRightLabel;
    UILabel *aggregationLabel;
    UILabel *periodLabel;
    UILabel *intervalLabel;
    UILabel *upperStudiesLabel;
    UILabel *lowerStudiesLabel;
    UILabel *selectStudyFirstLabel;
    UILabel *selectStudySecondLabel;
    UILabel *selectStudyThirdLabel;
    
    UIButton *intradayButton;
    UIButton *dailyButton;
    UIButton *selectStudyFirstButton;
    UIButton *selectStudySecondButton;
    UIButton *selectStudyThirdButton;
    
    UITextField *barsToRightTextField;
    UIButton *buttonForBarsToRightTextField;
    
    UIImageView *typeImageView;
    UIImageView *periodImageView;
    UIImageView *intervalImageView;
    
    UIButton *resetChartSettingsButton;
}

@property (nonatomic, unsafe_unretained) id <ChartSetupViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *barsToRightLabel;
@property (nonatomic, strong) IBOutlet UILabel *aggregationLabel;
@property (nonatomic, strong) IBOutlet UILabel *periodLabel;
@property (nonatomic, strong) IBOutlet UILabel *intervalLabel;
@property (nonatomic, strong) IBOutlet UILabel *upperStudiesLabel;
@property (nonatomic, strong) IBOutlet UILabel *lowerStudiesLabel;
@property (nonatomic, strong) IBOutlet UILabel *selectStudyFirstLabel;
@property (nonatomic, strong) IBOutlet UILabel *selectStudySecondLabel;
@property (nonatomic, strong) IBOutlet UILabel *selectStudyThirdLabel;

@property (nonatomic, strong) IBOutlet UIButton *intradayButton;
@property (nonatomic, strong) IBOutlet UIButton *dailyButton;
@property (nonatomic, strong) IBOutlet UIButton *selectStudyFirstButton;
@property (nonatomic, strong) IBOutlet UIButton *selectStudySecondButton;
@property (nonatomic, strong) IBOutlet UIButton *selectStudyThirdButton;

@property (nonatomic, strong) IBOutlet UITextField *barsToRightTextField;
@property (nonatomic, strong) IBOutlet UIButton *buttonForBarsToRightTextField;

@property (nonatomic, strong) IBOutlet UIImageView *typeImageView;
@property (nonatomic, strong) IBOutlet UIImageView *periodImageView;
@property (nonatomic, strong) IBOutlet UIImageView *intervalImageView;

@property (nonatomic, strong) IBOutlet UIButton *resetChartSettingsButton;

- (IBAction)intradayOrDailyButtonPresser:(id)sender;
- (IBAction)selectStudyButtonPressed:(UIButton *)sender;

- (IBAction)resetChartSettingsButtonPressed:(id)sender;

- (IBAction)backgroundTouch:(id)sender;

@end
