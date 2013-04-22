//
//  OrderEditorViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 10/11/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OrderEditorViewController.h"
#import "HorizontalPicker.h"

@interface OrderEditorViewController()
{
    HorizontalPicker *sidePicker;
    HorizontalPicker *typePicker;
    HorizontalPicker *tifPicker;
    UIAlertView *wrongTextFieldValueAlert;
    
    NSInteger sidePickerSelectedValue;
    NSInteger typePickerSelectedValue;
    NSInteger tifPickerSelectedValue;

    NSString *wrongTextFieldValueAlertMessage;
    NSString *errorText;
    NSString *okText;
    NSString *sendOrderButtonText;
    NSString *cancelButtonText;
    NSString *bidAskSizeText;
    NSString *editButtonText;
    NSString *sendText;
    NSString *orderConfirmationText;
}

@property (nonatomic, strong) HorizontalPicker *sidePicker;
@property (nonatomic, strong) HorizontalPicker *typePicker;
@property (nonatomic, strong) HorizontalPicker *tifPicker;
@property (nonatomic, strong) UIAlertView *wrongTextFieldValueAlert;

@property (nonatomic, copy) NSString *wrongTextFieldValueAlertMessage;
@property (nonatomic, copy) NSString *errorText;
@property (nonatomic, copy) NSString *okText;
@property (nonatomic, copy) NSString *sendOrderButtonText;
@property (nonatomic, copy) NSString *cancelButtonText;
@property (nonatomic, copy) NSString *bidAskSizeText;
@property (nonatomic, copy) NSString *editButtonText;
@property (nonatomic, copy) NSString *sendText;
@property (nonatomic, copy) NSString *orderConfirmationText;

- (void)localize;
- (void)createBarButtonItems;
- (UIButton *)createOrangeButton;
- (void)createPickers;
- (void)createBorderLabels;
- (void)createBorderLabel:(UILabel *)label;
- (void)updateLimitTextField;
- (void)sidePickerSelectValue:(NSInteger)value;
- (void)typePickerSelectValue:(NSInteger)value;
- (void)hideLimitField;
- (void)showLimitField;
- (void)tifPickerSelectValue:(NSInteger)value;
- (NSString *)textForConfirmationSheet;
- (void)sidePickerSelectValue:(NSInteger)value;
- (void)updateCostTradeValue;
@end

@implementation OrderEditorViewController
@synthesize symbolLabel;
@synthesize lastLabel;
@synthesize bidLabel;
@synthesize askLabel;

@synthesize symbolShort;
@synthesize symbolLong;
@synthesize price;
@synthesize netChange;
@synthesize bidPrice;
@synthesize bidSize;
@synthesize askPrice;
@synthesize askSize;

@synthesize sideLabel;
@synthesize quantityLabel;
@synthesize typeLabel;
@synthesize limitLabel;
@synthesize costOfTraideLabel;
@synthesize commissionLabel;
@synthesize tifLabel;

@synthesize costLabel;

@synthesize quantityTextField, limitTextField;
@synthesize sideHelperLabel, typeHelperLabel, tifHelperLabel;

@synthesize sideBorderLabel, typeBorderLabel, costOfTradeBorderLabel, tifBorderLabel;

@synthesize limitLockImageView;
@synthesize typeDarkGreyLine;

@synthesize lowerPartView;

@synthesize disableTextFieldButton;

@synthesize sidePicker;
@synthesize typePicker;
@synthesize tifPicker;
@synthesize wrongTextFieldValueAlert;

@synthesize wrongTextFieldValueAlertMessage, errorText, okText;
@synthesize sendOrderButtonText, cancelButtonText, bidAskSizeText;
@synthesize editButtonText, sendText, orderConfirmationText;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    [self createBarButtonItems];
    [self createPickers];
    [self createBorderLabels];
}

#pragma mark - Setters/Getters

- (UIAlertView *)wrongTextFieldValueAlert
{
    if (!wrongTextFieldValueAlert) {
        wrongTextFieldValueAlert = [[UIAlertView alloc] initWithTitle:self.errorText
                                                              message:self.wrongTextFieldValueAlertMessage
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:self.okText, nil];
    }
    return wrongTextFieldValueAlert;
}

#pragma mark - TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.disableTextFieldButton.hidden = NO;
    if ([textField isEqual:self.limitTextField]) {
        self.limitLockImageView.highlighted = YES;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -85);
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{    
    if ([textField isEqual:self.limitTextField]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
        self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, 85);
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateCostTradeValue];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL answer = NO;
    NSNumberFormatter *numForm = [[NSNumberFormatter alloc] init];
    if ([numForm numberFromString:string] || [string isEqualToString:@""]) {
        answer = YES;
    }
    
    if ([string isEqualToString:numForm.decimalSeparator] && ([textField.text rangeOfString:numForm.decimalSeparator].location == NSNotFound)) {
        answer = YES;
    }
    
    return answer;
}

#pragma mark - UIImage animation delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([@"typePickerDeselectedMarker" isEqual:animationID]) {
        self.limitLockImageView.hidden = NO;
        self.limitLabel.hidden = NO;
        self.limitTextField.hidden = NO;
    }
}

#pragma mark - HorizontalPicker delegate

- (void)horisontalPicker:(HorizontalPicker *)picker hasSelected:(NSInteger)number
{
    if ([picker isEqual:self.sidePicker]) {
        [self sidePickerSelectValue:number];
    } else if ([picker isEqual:self.typePicker]) {
        [self typePickerSelectValue:number];
    } else if ([picker isEqual:self.tifPicker]) {
        [self tifPickerSelectValue:number];
    }
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Sending");
    }
}

#pragma mark - Buttons

- (void)sendOrderButtonPressed
{
    if (self.quantityTextField.text && self.limitTextField.text) {
        UIActionSheet *confirmationActionSheet = [[UIActionSheet alloc] initWithTitle:[self textForConfirmationSheet]
                                                                             delegate:self
                                                                    cancelButtonTitle:self.editButtonText
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:self.sendText, nil];
        [confirmationActionSheet showInView:[self.view window]];
    }
}

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)disableTextFieldButtonPressed
{
    [self.quantityTextField resignFirstResponder];
    [self.limitTextField resignFirstResponder];
    self.disableTextFieldButton.hidden = YES;
}

#pragma mark - Instance methods

- (void)updateViewWithSymbol:(SymbolStorage *)symbol
{ 
    self.symbolShort.text = symbol.symbolShortName;
    self.symbolLong.text = symbol.symbolLongName;
    self.price.text = symbol.symbolPrice;
    
    if ([symbol.symbolPriceNetChange floatValue] < 0) {
        self.netChange.textColor = [UIColor redColor];
    } else {
        self.netChange.textColor = [UIColor greenColor];
    }
    self.netChange.text = symbol.symbolPriceNetChange;
    
    self.bidPrice.text = symbol.symbolBidPrice;
    self.bidSize.text = [self.bidAskSizeText stringByAppendingFormat:@" %@", symbol.symbolBidSize];
    self.askPrice.text = symbol.symbolAskPrice;
    self.askSize.text = [self.bidAskSizeText stringByAppendingFormat:@" %@", symbol.symbolAskSize];
    
    if (!self.limitLockImageView.highlighted) {
        // lock is green, we must update it
        [self updateLimitTextField];
    }
    
}

#pragma mark - Supporting methods

- (void)localize
{
    self.title = NSLocalizedString(@"Order Editor", nil);
    self.sendOrderButtonText = NSLocalizedString(@"Send Order", nil);
    self.cancelButtonText = NSLocalizedString(@"Cancel", nil);
    
    NSMutableString *size = [NSMutableString stringWithString:NSLocalizedString(@"Size", nil)];
    size = [NSMutableString stringWithString:[size lowercaseString]];
    [size appendFormat:@":"];
    self.bidAskSizeText = size;
    
    self.symbolLabel.text = NSLocalizedString(@"Symbol", nil);
    self.lastLabel.text = NSLocalizedString(@"Last", nil);
    self.bidLabel.text = NSLocalizedString(@"Bid", nil);
    self.askLabel.text = NSLocalizedString(@"Ask", nil);
    
    self.sideLabel.text = NSLocalizedString(@"Side", nil);
    self.quantityLabel.text = NSLocalizedString(@"Quantity", nil);
    self.typeLabel.text = NSLocalizedString(@"Type", nil);
    self.limitLabel.text = NSLocalizedString(@"Limit", nil);
    self.costOfTraideLabel.text = NSLocalizedString(@"Cost of Trade", nil);
    self.commissionLabel.text = NSLocalizedString(@"+ commission", nil);
    self.tifLabel.text = NSLocalizedString(@"TIF", nil);
    
    self.editButtonText = NSLocalizedString(@"Edit", nil);
    self.sendText = NSLocalizedString(@"Send", nil);
    self.orderConfirmationText = NSLocalizedString(@"Order confirmation", nil);
}



- (void)createBarButtonItems
{
    UIButton *orangeButton = [self createOrangeButton];
    UIBarButtonItem *sendOrderButton = [[UIBarButtonItem alloc] initWithCustomView:orangeButton];
    self.navigationItem.rightBarButtonItem = sendOrderButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:self.cancelButtonText 
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (UIButton *)createOrangeButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_orange_gradient.png"] forState:UIBarButtonItemStylePlain];
    [button setTitle:self.sendOrderButtonText forState:UIBarButtonItemStylePlain];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    button.titleLabel.shadowColor = [UIColor blackColor];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor: [[UIColor grayColor] CGColor]];
    button.frame=CGRectMake(0.0, 100.0, 80.0, 30.0);
    [button addTarget:self action:@selector(sendOrderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)createPickers
{
    self.sidePicker = [[HorizontalPicker alloc] initWithArrayOfNSString:[NSArray arrayWithObjects:@"BUY", @"SELL", nil]
                                                                        andFrame:self.sideHelperLabel.frame];
    [self.view addSubview:self.sidePicker.scrollView];
    self.sidePicker.delegate = self;
    
    self.typePicker = [[HorizontalPicker alloc] initWithArrayOfNSString:[NSArray arrayWithObjects:@"LIMIT", @"MARKET", @"STOPLOSS", nil]
                                                               andFrame:self.typeHelperLabel.frame];
    [self.view addSubview:self.typePicker.scrollView];
    self.typePicker.delegate = self;
    
    self.tifPicker = [[HorizontalPicker alloc] initWithArrayOfNSString:[NSArray arrayWithObjects:@"DAY", @"GTC", nil]
                                                               andFrame:self.tifHelperLabel.frame];
    [self.lowerPartView addSubview:self.tifPicker.scrollView];
    self.tifPicker.delegate = self;
    
}

- (void)createBorderLabels
{
    [self createBorderLabel:self.sideBorderLabel];
    [self createBorderLabel:self.typeBorderLabel];
    [self createBorderLabel:self.costOfTradeBorderLabel];
    [self createBorderLabel:self.tifBorderLabel];
}

- (void)createBorderLabel:(UILabel *)label
{
    label.layer.cornerRadius = 7;
    label.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    label.layer.borderWidth = 1;
}

- (void)updateLimitTextField
{
    if (sidePickerSelectedValue == 0) {
        // BUY
        self.limitTextField.text = self.askPrice.text;
    } else {
        // SELL
        self.limitTextField.text = self.bidPrice.text;
    }
    [self updateCostTradeValue];
}
- (void)typePickerSelectValue:(NSInteger)value
{
    self.limitLockImageView.highlighted = NO;
    typePickerSelectedValue = value;
    if (typePickerSelectedValue == 1) {
        // MARKET
        [self hideLimitField];
    } else {
        [self showLimitField];
    }
    
}

- (void)hideLimitField
{
    self.limitLockImageView.hidden = YES;
    self.limitLabel.hidden = YES;
    self.limitTextField.hidden = YES;
    self.typeDarkGreyLine.hidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.1];
    self.typeBorderLabel.frame = CGRectMake(self.typeBorderLabel.frame.origin.x, self.typeBorderLabel.frame.origin.y,
                                            self.typeBorderLabel.frame.size.width, 41);
    self.lowerPartView.frame = CGRectMake(0, 220, self.lowerPartView.frame.size.width, self.lowerPartView.frame.size.height);
    [UIView commitAnimations];
}

- (void)showLimitField
{
    self.typeDarkGreyLine.hidden = NO;
    [UIView beginAnimations:@"typePickerDeselectedMarker" context:nil];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    self.typeBorderLabel.frame = CGRectMake(self.typeBorderLabel.frame.origin.x, self.typeBorderLabel.frame.origin.y,
                                            self.typeBorderLabel.frame.size.width, 79);
    self.lowerPartView.frame = CGRectMake(0, 258, self.lowerPartView.frame.size.width, self.lowerPartView.frame.size.height);
    [UIView commitAnimations];
}

- (void)tifPickerSelectValue:(NSInteger)value
{
    tifPickerSelectedValue = value;
}

- (NSString *)textForConfirmationSheet
{
    NSString *sidePickerText;
    if (sidePickerSelectedValue == 0) {
        sidePickerText = @"BUY";
    } else {
        sidePickerText = @"SELL";
    }
    NSString *text = [self.orderConfirmationText stringByAppendingFormat:@"\n%@\n%@ +%@", 
                      self.symbolShort.text, sidePickerText, self.quantityTextField.text];
    if (!self.limitLabel.hidden) {
        text = [text stringByAppendingFormat:@" @%@ LMT", self.limitTextField.text];
    }
    return text;
}

- (void)sidePickerSelectValue:(NSInteger)value
{
    self.limitLockImageView.highlighted = NO;
    sidePickerSelectedValue = value;
    [self updateLimitTextField];
}
- (void)updateCostTradeValue
{
    float quantity = [self.quantityTextField.text floatValue];
    float limit = [self.limitTextField.text floatValue];
    self.costLabel.text = [NSString stringWithFormat:@"$%.2f", quantity*limit];
}

@end
