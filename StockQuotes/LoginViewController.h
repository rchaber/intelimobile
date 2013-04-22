//
//  LoginViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/28/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountViewController.h"

@interface LoginViewController : UIViewController <AccountViewControllerExitDelegate>
{
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UILabel *rememberMeLabel;
    UIButton *logInButton;
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UISwitch *rememberMeSwitch;
}

@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel *passwordLabel;
@property (nonatomic, strong) IBOutlet UILabel *rememberMeLabel;
@property (nonatomic, strong) IBOutlet UIButton *logInButton;
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UISwitch *rememberMeSwitch;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *registerButton;

- (IBAction)logInButtonPressed:(id)sender;

@end