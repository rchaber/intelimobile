//
//  AccountViewController.h
//  StockQuotes
//
//  Created by Dmitriy Vorobjov on 2/3/12.
//  Copyright (c) 2012 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountViewController;
@protocol AccountViewControllerExitDelegate <NSObject>

- (void)accountViewControllerExitSend:(AccountViewController *)accountViewController;

@end

@interface AccountViewController : UIViewController

@property (nonatomic, unsafe_unretained) id <AccountViewControllerExitDelegate> exitDelegate;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *firstBorderView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *accountNumberLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *usernameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *emailLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *accountNumberValueLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLastNameValueLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *usernameValueLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *emailValueLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *editAccountInfoButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *secondBorderView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *cashLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *buyPowerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *portfolioValueLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *cashPlusPortfolioLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *thirdBorderView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *profitLossLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *yearToDateNetLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *yearToDatePercentLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *sinceInceptionNetLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *sinceInceptionPercentLabel;

@end
