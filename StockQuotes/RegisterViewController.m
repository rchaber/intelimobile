//
//  RegisterViewController.m
//  StockQuotes
//
//  Created by Dmitriy Vorobjov on 2/3/12.
//  Copyright (c) 2012 Polecat. All rights reserved.
//

#import "RegisterViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface RegisterViewController()

@property (nonatomic, unsafe_unretained) CGPoint borderViewDefaultCoordinates;

- (void)localize;
- (void)configureScreen;
- (void)createBorders;

@end

@implementation RegisterViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self localize];
    [self configureScreen];
    [self createBorders];
}

- (void)viewDidUnload {
    [self setToRegisterTextLabel:nil];
    [self setNameLabel:nil];
    [self setLastNameLabel:nil];
    [self setUsernameLabel:nil];
    [self setEmailLabel:nil];
    [self setPasswordLabel:nil];
    [self setReenterLabel:nil];
    [self setActivationLinkTextLabel:nil];
    [self setSubmitButton:nil];
    [self setNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setUserNameTextField:nil];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setReenterTextField:nil];
    [self setBorderView:nil];
    [self setCheckmarkImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Methods

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitButtonPressed 
{    
    BOOL isSomethingMissing = NO;
    
    if ((! self.nameTextField.text) || [self.nameTextField.text isEqualToString:@""]) {
        isSomethingMissing = YES;
    }
    if ((! self.lastNameTextField.text) || [self.lastNameTextField.text isEqualToString:@""]) {
        isSomethingMissing = YES;
    }
    if ((! self.userNameTextField.text) || [self.userNameTextField.text isEqualToString:@""]) {
        isSomethingMissing = YES;
    }
    if ((! self.emailTextField.text) || [self.emailTextField.text isEqualToString:@""]) {
        isSomethingMissing = YES;
    }
    if ((! self.passwordTextField.text) || [self.passwordTextField.text isEqualToString:@""]) {
        isSomethingMissing = YES;
    }
    if ((! self.reenterTextField.text) || [self.reenterTextField.text isEqualToString:@""]) {
        isSomethingMissing = YES;
    }
    
    if (isSomethingMissing) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                            message:NSLocalizedString(@"Please fill all fields.", NULL)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else {
        if ([self.passwordTextField.text isEqualToString:self.reenterTextField.text]) {
            // all is ok
            NSString *message = [NSString stringWithFormat:@"%@ %@ %@", 
                                 NSLocalizedString(@"An email was sent to", NULL),
                                 self.emailTextField.text,
                                 NSLocalizedString(@"with activation link.", NULL)];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil 
                                                                message:message 
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                                message:NSLocalizedString(@"Both passwords must match.", NULL) 
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                      otherButtonTitles:nil];
            [alertView show];
            self.passwordTextField.text = @"";
            self.reenterTextField.text = @"";
        }
    }
}

#pragma mark - TextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint newCoordinates = self.borderViewDefaultCoordinates;
    CGFloat delta = self.lastNameTextField.frame.origin.y - self.nameTextField.frame.origin.y;
    
    if ([textField isEqual:self.userNameTextField]) {
        newCoordinates.y -= delta;
    }
    else if ([textField isEqual:self.emailTextField]) {
        newCoordinates.y -= 2 * delta;
    }
    else if ([textField isEqual:self.passwordTextField] || [textField isEqual:self.reenterTextField]) {
        newCoordinates.y -= 3 * delta;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.borderView.frame = CGRectMake(newCoordinates.x, newCoordinates.y,
                                       self.borderView.frame.size.width, self.borderView.frame.size.height);
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.userNameTextField]) {
        if (self.userNameTextField.text && ! [self.userNameTextField.text isEqualToString:@""]) {
            self.checkmarkImageView.hidden = NO;
        }
        else 
        {
            self.checkmarkImageView.hidden = YES;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)tField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.borderView.frame = CGRectMake(self.borderViewDefaultCoordinates.x, self.borderViewDefaultCoordinates.y,
                                       self.borderView.frame.size.width, self.borderView.frame.size.height);
    [UIView commitAnimations];
    
    [tField resignFirstResponder];
    return YES;
}

#pragma mark - Supporting methods

- (void)localize
{
    self.toRegisterTextLabel.text = NSLocalizedString(@"To register, please, fill in all fields:", NULL);
    self.nameLabel.text = NSLocalizedString(@"Name", NULL);
    self.lastNameLabel.text = NSLocalizedString(@"Last name", NULL);
    self.usernameLabel.text = NSLocalizedString(@"Username", NULL);
    self.emailLabel.text = NSLocalizedString(@"E-mail", NULL);
    self.passwordLabel.text = NSLocalizedString(@"Password", NULL);
    self.reenterLabel.text = NSLocalizedString(@"Re-enter", NULL);
    self.activationLinkTextLabel.text = NSLocalizedString(@"Activation link will be send to provided email.", NULL);
}

- (void)configureScreen
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", NULL)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.borderViewDefaultCoordinates = CGPointMake(self.borderView.frame.origin.x, self.borderView.frame.origin.y);
}

- (void)createBorders
{
    self.borderView.layer.cornerRadius = 7;
    self.borderView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.54 blue:0.54 alpha:1].CGColor;
    self.borderView.layer.borderWidth = 1;
}

#pragma mark - Properties

@synthesize borderView = _borderView;
@synthesize toRegisterTextLabel = _toRegisterTextLabel;
@synthesize nameLabel = _nameLabel;
@synthesize lastNameLabel = _lastNameLabel;
@synthesize usernameLabel = _usernameLabel;
@synthesize emailLabel = _emailLabel;
@synthesize passwordLabel = _passwordLabel;
@synthesize reenterLabel = _reenterLabel;
@synthesize activationLinkTextLabel = _activationLinkTextLabel;
@synthesize submitButton = _submitButton;
@synthesize nameTextField = _nameTextField;
@synthesize lastNameTextField = _lastNameTextField;
@synthesize userNameTextField = _userNameTextField;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize reenterTextField = _reenterTextField;
@synthesize checkmarkImageView = _checkmarkImageView;

@synthesize borderViewDefaultCoordinates = _borderViewDefaultCoordinates;

@end
