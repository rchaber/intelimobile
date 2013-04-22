//
//  ConnectionSettingsViewController.m
//  StockQuotes
//
//  Created by Admin on 9/29/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "ConnectionSettingsViewController.h"
#import "p9mdi_client.h"

@interface ConnectionSettingsViewController()
{
    UIAlertView *tooLongPortAlert;
    
    NSString *connectionErrorText;
    NSString *connectionOkText;
    NSString *tooLongPortAlertTitle;
    NSString *tooLongPortAlertMessage;
}
@property (nonatomic, strong) UIAlertView *tooLongPortAlert;
@property (nonatomic, copy) NSString *connectionErrorText;
@property (nonatomic, copy) NSString *connectionOkText;
@property (nonatomic, copy) NSString *tooLongPortAlertTitle;
@property (nonatomic, copy) NSString *tooLongPortAlertMessage;

- (void)localize;
- (void)createAndConfigureBarButtonItems;
- (void)loadServerAndPortFromUserDefaults;
@end

@implementation ConnectionSettingsViewController

@synthesize serverLabel;
@synthesize portLabel;
@synthesize serverTextField;
@synthesize portTextField;

@synthesize tooLongPortAlert;
@synthesize connectionErrorText, connectionOkText, tooLongPortAlertTitle, tooLongPortAlertMessage;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    [self createAndConfigureBarButtonItems];
    [self loadServerAndPortFromUserDefaults];
}

#pragma mark - Setters/Getters

- (UIAlertView *)tooLongPortAlert
{
    if (!tooLongPortAlert) {
        tooLongPortAlert = [[UIAlertView alloc] initWithTitle:self.tooLongPortAlertTitle 
                                                      message:self.tooLongPortAlertMessage
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:connectionOkText, nil];
    }
    return tooLongPortAlert;
}

#pragma mark - Buttons

- (void)doneButtonPressed
{
    NSDictionary *connectionSettings = [NSDictionary dictionaryWithObjectsAndKeys:self.serverTextField.text, @"server",
                                                                                  self.portTextField.text, @"port",
                                                                                  nil];
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    [standartUserDefaults setObject:connectionSettings forKey:@"connection settings"];
    [standartUserDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)tField
{
    BOOL answer = NO;
    
    if ([tField isEqual:self.serverTextField]) {
        answer = YES;
        [self.serverTextField resignFirstResponder];
    } else if ([tField isEqual:self.portTextField]) {
        if ([tField.text length] > 5) {
            [self.tooLongPortAlert show];
        } else {
            answer = YES;
            [self.portTextField resignFirstResponder];
        }
    }
    
    return answer;
}

#pragma mark - Supporting methods

- (void)localize
{
    self.serverLabel.text = NSLocalizedString(@"Server", nil);
    self.portLabel.text = NSLocalizedString(@"Port", nil);
    self.connectionErrorText = NSLocalizedString(@"Error", nil);
    self.connectionOkText = NSLocalizedString(@"OK", nil);
    self.tooLongPortAlertTitle = NSLocalizedString(@"Error", nil);
    self.tooLongPortAlertMessage = NSLocalizedString(@"Too long port", nil);
}

- (void)createAndConfigureBarButtonItems
{
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                target:self
                                                                                action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)loadServerAndPortFromUserDefaults
{
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    self.serverTextField.text = [[standartUserDefaults objectForKey:@"connection settings"] objectForKey:@"server"];
    self.portTextField.text = [[standartUserDefaults objectForKey:@"connection settings"] objectForKey:@"port"];
}

@end
