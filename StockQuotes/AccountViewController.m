//
//  AccountViewController.m
//  StockQuotes
//
//  Created by Dmitriy Vorobjov on 2/3/12.
//  Copyright (c) 2012 Polecat. All rights reserved.
//

#import "AccountViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface AccountViewController()

- (void)localize;
- (void)configureScreen;
- (void)createBorders;

@end

@implementation AccountViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    [self configureScreen];
}

- (void)viewDidUnload {
    [self setFirstBorderView:nil];
    [self setSecondBorderView:nil];
    [self setThirdBorderView:nil];
    [self setScrollView:nil];
    [self setAccountNumberLabel:nil];
    [self setUsernameLabel:nil];
    [self setEmailLabel:nil];
    [self setAccountNumberValueLabel:nil];
    [self setNameLastNameValueLabel:nil];
    [self setUsernameValueLabel:nil];
    [self setEmailValueLabel:nil];
    [self setEditAccountInfoButton:nil];
    [self setCashLabel:nil];
    [self setBuyPowerLabel:nil];
    [self setProfitLossLabel:nil];
    [self setPortfolioValueLabel:nil];
    [self setCashPlusPortfolioLabel:nil];
    [self setYearToDateNetLabel:nil];
    [self setYearToDatePercentLabel:nil];
    [self setSinceInceptionNetLabel:nil];
    [self setSinceInceptionPercentLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Methods

- (void)exitButtonPressed
{
    [self.exitDelegate accountViewControllerExitSend:self];
}

- (IBAction)editAccountButtonPressed:(id)sender 
{
    
}

#pragma mark - Supporting methods

- (void)localize
{
    self.accountNumberLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Account Number", NULL)];
    self.usernameLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Username", NULL)];
    self.emailLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"E-mail", NULL)];
    [self.editAccountInfoButton setTitle:NSLocalizedString(@"edit account info", NULL) forState:UIControlStateNormal];
    
    self.cashLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Cash", NULL)];
    self.buyPowerLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Buying Power", NULL)];
    self.portfolioValueLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Portfolio Value", NULL)];
    self.cashPlusPortfolioLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Cash + Portfolio", NULL)];
    
    self.profitLossLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Profit / Loss", NULL)];
    self.yearToDateNetLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Year-to-date Net", NULL)];
    self.yearToDatePercentLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Year-to-date %", NULL)];
    self.sinceInceptionNetLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Since Inception Net", NULL)];
    self.sinceInceptionPercentLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Since Inception %", NULL)];
}

- (void)configureScreen
{
    [self createBorders];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Exit", NULL)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(exitButtonPressed)];
    self.navigationItem.leftBarButtonItem = exitButton;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 564);
}

- (void)createBorders
{
    self.firstBorderView.layer.cornerRadius = 7;
    self.firstBorderView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    self.firstBorderView.layer.borderWidth = 1;
    
    self.secondBorderView.layer.cornerRadius = 7;
    self.secondBorderView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    self.secondBorderView.layer.borderWidth = 1;
    
    self.thirdBorderView.layer.cornerRadius = 7;
    self.thirdBorderView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    self.thirdBorderView.layer.borderWidth = 1;
    
    self.editAccountInfoButton.layer.cornerRadius = 7;
    self.editAccountInfoButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.editAccountInfoButton.layer.borderWidth = 1;
}

@synthesize exitDelegate = _exitDelegate;
@synthesize scrollView = _scrollView;
@synthesize accountNumberLabel = _accountNumberLabel;
@synthesize usernameLabel = _usernameLabel;
@synthesize emailLabel = _emailLabel;
@synthesize accountNumberValueLabel = _accountNumberValueLabel;
@synthesize nameLastNameValueLabel = _nameLastNameValueLabel;
@synthesize usernameValueLabel = _usernameValueLabel;
@synthesize emailValueLabel = _emailValueLabel;
@synthesize editAccountInfoButton = _editAccountInfoButton;
@synthesize firstBorderView = _firstBorderView;
@synthesize secondBorderView = _secondBorderView;
@synthesize cashLabel = _cashLabel;
@synthesize buyPowerLabel = _buyPowerLabel;
@synthesize portfolioValueLabel = _portfolioValueLabel;
@synthesize cashPlusPortfolioLabel = _cashPlusPortfolioLabel;
@synthesize thirdBorderView = _thirdBorderView;
@synthesize profitLossLabel = _profitLossLabel;
@synthesize yearToDateNetLabel = _yearToDateNetLabel;
@synthesize yearToDatePercentLabel = _yearToDatePercentLabel;
@synthesize sinceInceptionNetLabel = _sinceInceptionNetLabel;
@synthesize sinceInceptionPercentLabel = _sinceInceptionPercentLabel;

@end
