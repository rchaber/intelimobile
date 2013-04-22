//
//  AddingSymbolViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/23/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddingSymbolViewControllerDelegate

- (void)newSymbolWasAdded:(NSString *)symbol withExchange:(NSString *)exchange;

@end

@interface AddingSymbolViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{ 
    UITextField *textField;
    UIButton *exchangeButton;
    UIView *viewForPicker;
    UIPickerView *picker;
    
    UILabel *theNewSymbolNameLabel;
    UILabel *exchangeLabel;
    UIBarButtonItem *pickerDoneButton;
    
    id <AddingSymbolViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *exchangeButton;
@property (nonatomic, strong) IBOutlet UIView *viewForPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;

@property (nonatomic, strong) IBOutlet UILabel *theNewSymbolNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *exchangeLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pickerDoneButton;

@property (nonatomic, unsafe_unretained) id <AddingSymbolViewControllerDelegate> delegate;

- (IBAction)exchangeButtonPressed:(id)sender;
- (IBAction)exchangeDoneButtonPressed:(id)sender;

@end
