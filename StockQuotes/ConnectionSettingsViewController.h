//
//  ConnectionSettingsViewController.h
//  StockQuotes
//
//  Created by Admin on 9/29/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionSettingsViewController : UIViewController <UITextFieldDelegate>
{
    UILabel *serverLabel;
    UILabel *portLabel;
    UITextField *serverTextField;
    UITextField *portTextField;
}

@property (nonatomic, strong) IBOutlet UILabel *serverLabel;
@property (nonatomic, strong) IBOutlet UILabel *portLabel;
@property (nonatomic, strong) IBOutlet UITextField *serverTextField;
@property (nonatomic, strong) IBOutlet UITextField *portTextField;

@end
