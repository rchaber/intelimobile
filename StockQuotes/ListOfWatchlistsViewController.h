//
//  ListOfWatchlistsViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/21/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@protocol ListOfWatchlistsViewControllerProtocol <NSObject>
- (void)listOfWatchlistsViewControllerFinishedWorking;
@end

@interface ListOfWatchlistsViewController : UITableViewController <RootViewControllerDelegate, UITextFieldDelegate>
{
    NSMutableDictionary *watchlists;
    
    UIView *tableHeaderView;
    UILabel *tableHeaderViewLabel;
    UITextField *tableHeaderViewTextField;
    UIButton *tableHeaderViewButton;

    UIImageView *checkmarkView;
    UITextField *textFieldForEditingTableRow;
}

@property (nonatomic, strong) NSMutableDictionary *watchlists;

@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;
@property (nonatomic, strong) IBOutlet UILabel *tableHeaderViewLabel;
@property (nonatomic, strong) IBOutlet UITextField *tableHeaderViewTextField;
@property (nonatomic, strong) IBOutlet UIButton *tableHeaderViewButton;

@property (nonatomic, strong) IBOutlet UIImageView *checkmarkView;
@property (nonatomic, strong) IBOutlet UITextField *textFieldForEditingTableRow;

@property (nonatomic, unsafe_unretained) id <ListOfWatchlistsViewControllerProtocol> delegate;

- (IBAction)plusButtonPressed:(id)sender;

@end
