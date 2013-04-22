//
//  LoginViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/28/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LoginViewController.h"
#import "ListOfWatchlistsViewController.h"
#import "ConnectionSettingsViewController.h"
#import "RegisterViewController.h"
#import "TATabBarController.h"
#import "AccountViewController.h"

@interface LoginViewController()
{
    NSString *settingsButtonText;
}
@property (nonatomic, copy) NSString *settingsButtonText;

- (void)localize;
- (void)createBarButtonItems;
@end

@implementation LoginViewController

@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize rememberMeLabel;
@synthesize logInButton;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize rememberMeSwitch;
@synthesize registerButton = _registerButton;

@synthesize settingsButtonText;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self localize];
    [self createBarButtonItems];
}

- (void)viewDidUnload {
    [self setRegisterButton:nil];
    [super viewDidUnload];
}

#pragma mark - Buttons

- (IBAction)logInButtonPressed:(id)sender
{
    ListOfWatchlistsViewController *lowvc = [[ListOfWatchlistsViewController alloc]
                                             initWithNibName:@"ListOfWatchlistsViewController" bundle:nil];
    
    UINavigationController *lowvcNavCon = [[UINavigationController alloc] initWithRootViewController:lowvc];
    lowvcNavCon.tabBarItem.image = [UIImage imageNamed:@"1318509461_lists_32.png"];
    lowvcNavCon.navigationBar.barStyle = UIBarStyleBlack;
    lowvcNavCon.navigationBar.frame = CGRectMake(0, 0, lowvcNavCon.navigationBar.frame.size.width, lowvcNavCon.navigationBar.frame.size.height);
    
    TATabBarController *tabBarCon = [[TATabBarController alloc] init];
    lowvc.delegate = tabBarCon;
    
    tabBarCon.view.backgroundColor = [UIColor blackColor];
    [tabBarCon setSelectedImageMask:[UIImage imageNamed:@"grad_orange2.png"]];
	[tabBarCon setUnselectedImageMask:[UIImage imageNamed:@"grad_grey.png"]];
    
    UIViewController *quotesViewCon = [[UIViewController alloc] init];
    quotesViewCon.title = NSLocalizedString(@"Quotes", nil);
    quotesViewCon.tabBarItem.image = [UIImage imageNamed:@"1318185200_arrow_32_2.png"];
    
    UIViewController *newsViewCon = [[UIViewController alloc] init];
    newsViewCon.title = NSLocalizedString(@"News", nil);
    newsViewCon.tabBarItem.image = [UIImage imageNamed:@"1318345425_news_32.png"];
    
    AccountViewController *accountViewCon = [[AccountViewController alloc] init];
    accountViewCon.exitDelegate = self;
    accountViewCon.title = NSLocalizedString(@"Account", nil);
    UINavigationController *accountNavCon = [[UINavigationController alloc] initWithRootViewController:accountViewCon];
    accountNavCon.navigationBar.barStyle = UIBarStyleBlack;
    accountNavCon.tabBarItem.image = [UIImage imageNamed:@"1318185139_money_32.png"];
    
    UIViewController *emptyViewCon = [[UIViewController alloc] init];
    emptyViewCon.title = NSLocalizedString(@"More", nil);
    emptyViewCon.tabBarItem.image = [UIImage imageNamed:@"dots.png"];
    
    tabBarCon.viewControllers = [NSArray arrayWithObjects:lowvcNavCon, quotesViewCon, newsViewCon, accountNavCon, emptyViewCon, nil];
    
    [tabBarCon setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:tabBarCon animated:YES];
}

- (IBAction)registerButtonPressed 
{
    RegisterViewController *registerViewController = [[RegisterViewController alloc] init];
    registerViewController.title = NSLocalizedString(@"Register", NULL);
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (void)settingsButtonPressed
{
    ConnectionSettingsViewController *csvc = [[ConnectionSettingsViewController alloc] init];
    [self.navigationController pushViewController:csvc animated:YES];
}

#pragma mark - AccountViewController exit delegate

- (void)accountViewControllerExitSend:(AccountViewController *)accountViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Supporting methods

- (void)localize
{
    self.title = NSLocalizedString(@"Intelitrader", nil);
    self.usernameLabel.text = NSLocalizedString(@"Username", nil);
    self.passwordLabel.text = NSLocalizedString(@"Password", nil);
    self.rememberMeLabel.text = NSLocalizedString(@"Remember me", nil);
    [self.logInButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    self.settingsButtonText = NSLocalizedString(@"Settings", nil);
    [self.registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
}

- (void)createBarButtonItems
{
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:self.settingsButtonText
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(settingsButtonPressed)];
    self.navigationItem.rightBarButtonItem = settingsButton;
}

@end
