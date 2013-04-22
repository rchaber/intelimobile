//
//  RegisterViewController.h
//  StockQuotes
//
//  Created by Dmitriy Vorobjov on 2/3/12.
//  Copyright (c) 2012 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIView *borderView;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *toRegisterTextLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *usernameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *emailLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *passwordLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *reenterLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *activationLinkTextLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *submitButton;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *nameTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *userNameTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *passwordTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *reenterTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end
