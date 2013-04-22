//
//  AddingSymbolViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/23/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "AddingSymbolViewController.h"

@interface AddingSymbolViewController()
{
    NSArray *exchanges;
    
    NSString *doneButtonText;
}
@property (nonatomic, copy) NSString *doneButtonText;
@end

@implementation AddingSymbolViewController

@synthesize textField;
@synthesize exchangeButton;
@synthesize viewForPicker;
@synthesize picker;

@synthesize doneButtonText, theNewSymbolNameLabel, exchangeLabel, pickerDoneButton;

@synthesize delegate;

#pragma mark - Buttons

- (IBAction)exchangeButtonPressed:(id)sender
{
    self.viewForPicker.hidden = NO;
    self.viewForPicker.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height, 
                                          self.viewForPicker.frame.size.width, self.viewForPicker.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.viewForPicker.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - self.viewForPicker.frame.size.height, 
                                          self.viewForPicker.frame.size.width, self.viewForPicker.frame.size.height);
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([@"exchangeDoneButtonPressed" isEqual:animationID]) {
        self.viewForPicker.hidden = YES;
    }
}

- (IBAction)exchangeDoneButtonPressed:(id)sender
{
    [UIView beginAnimations:@"exchangeDoneButtonPressed" context:NULL];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    self.viewForPicker.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height, 
                                          self.viewForPicker.frame.size.width, self.viewForPicker.frame.size.height);
    [UIView commitAnimations];
}

- (void)doneButtonPressed
{
    [self.delegate newSymbolWasAdded:self.textField.text withExchange:self.exchangeButton.titleLabel.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Picker delegate methods

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.bounds.size.width;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [exchanges objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.exchangeButton setTitle:[exchanges objectAtIndex:row] forState:UIControlStateNormal];
}

#pragma mark - Picker dataSource methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [exchanges count];
}

#pragma mark - TextField delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)tField
{
    BOOL answer = NO;
    
    if ([tField isEqual:self.textField]) {
        answer = YES;
        [self.textField resignFirstResponder];
        self.textField.text = [self.textField.text uppercaseString];
        
        // now we have symbol's name - allow to add symbol
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:self.doneButtonText 
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }

    return answer;
}

#pragma mark - View lifecycle

- (void)localize
{
    self.textField.placeholder = NSLocalizedString(@"name", nil);
    self.doneButtonText = NSLocalizedString(@"Done", nil);
    self.theNewSymbolNameLabel.text = NSLocalizedString(@"New Symbol Name", nil);
    self.exchangeLabel.text = NSLocalizedString(@"Exchange", nil);
    self.pickerDoneButton.title = NSLocalizedString(@"Done", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localize];
    
    exchanges = [[NSArray alloc] initWithObjects:@"NASDAQ", @"NYSE", @"BVMF", nil];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.textField.delegate = self;
    [self.exchangeButton setTitle:[exchanges objectAtIndex:0] forState:UIControlStateNormal];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self.view addSubview:self.viewForPicker];
}

@end
