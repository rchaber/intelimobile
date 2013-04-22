//
//  OrderEditorViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 10/11/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SymbolStorage.h"
#import "HorizontalPicker.h"

@interface OrderEditorViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, HorizontalPickerDelegate>
{
    UILabel *symbolLabel;
    UILabel *lastLabel;
    UILabel *bidLabel;
    UILabel *askLabel;

    UILabel *symbolShort;
    UILabel *symbolLong;
    UILabel *price;
    UILabel *netChange;
    UILabel *bidPrice;
    UILabel *bidSize;
    UILabel *askPrice;
    UILabel *askSize;
    
    UILabel *sideLabel;
    UILabel *quantityLabel;
    UILabel *typeLabel;
    UILabel *limitLabel;
    UILabel *costOfTraideLabel;
    UILabel *commissionLabel;
    UILabel *tifLabel;
    
    UILabel *costLabel;
    
    UITextField *quantityTextField;
    UITextField *limitTextField;
    UILabel *sideHelperLabel;
    UILabel *typeHelperLabel;
    UILabel *tifHelperLabel;
    
    UILabel *sideBorderLabel;
    UILabel *typeBorderLabel;
    UILabel *costOfTradeBorderLabel;
    UILabel *tifBorderLabel;
    
    UIImageView *limitLockImageView;
    UIImageView *typeDarkGreyLine;
    
    UIView *lowerPartView;
    
    UIButton *disableTextFieldButton;
}

@property (nonatomic, strong) IBOutlet UILabel *symbolLabel;
@property (nonatomic, strong) IBOutlet UILabel *lastLabel;
@property (nonatomic, strong) IBOutlet UILabel *bidLabel;
@property (nonatomic, strong) IBOutlet UILabel *askLabel;

@property (nonatomic, strong) IBOutlet UILabel *symbolShort;
@property (nonatomic, strong) IBOutlet UILabel *symbolLong;
@property (nonatomic, strong) IBOutlet UILabel *price;
@property (nonatomic, strong) IBOutlet UILabel *netChange;
@property (nonatomic, strong) IBOutlet UILabel *bidPrice;
@property (nonatomic, strong) IBOutlet UILabel *bidSize;
@property (nonatomic, strong) IBOutlet UILabel *askPrice;
@property (nonatomic, strong) IBOutlet UILabel *askSize;

@property (nonatomic, strong) IBOutlet UILabel *sideLabel;
@property (nonatomic, strong) IBOutlet UILabel *quantityLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *limitLabel;
@property (nonatomic, strong) IBOutlet UILabel *costOfTraideLabel;
@property (nonatomic, strong) IBOutlet UILabel *commissionLabel;
@property (nonatomic, strong) IBOutlet UILabel *tifLabel;

@property (nonatomic, strong) IBOutlet UILabel *costLabel;

@property (nonatomic, strong) IBOutlet UITextField *quantityTextField;
@property (nonatomic, strong) IBOutlet UITextField *limitTextField;
@property (nonatomic, strong) IBOutlet UILabel *sideHelperLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeHelperLabel;
@property (nonatomic, strong) IBOutlet UILabel *tifHelperLabel;

@property (nonatomic, strong) IBOutlet UILabel *sideBorderLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeBorderLabel;
@property (nonatomic, strong) IBOutlet UILabel *costOfTradeBorderLabel;
@property (nonatomic, strong) IBOutlet UILabel *tifBorderLabel;

@property (nonatomic, strong) IBOutlet UIImageView *limitLockImageView;
@property (nonatomic, strong) IBOutlet UIImageView *typeDarkGreyLine;

@property (nonatomic, strong) IBOutlet UIView *lowerPartView;

@property (nonatomic, strong) IBOutlet UIButton *disableTextFieldButton;

- (void)updateViewWithSymbol:(SymbolStorage *)symbol;

- (IBAction)disableTextFieldButtonPressed;

@end
