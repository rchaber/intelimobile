//
//  RootViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "AddingSymbolViewController.h"
#import "NetworkControllerProtocol.h"

@protocol RootViewControllerDelegate
@required
- (void)watchlistInRootViewControllerHasChanged:(NSArray *)wlist;
- (void)rootViewControllerFinishedWorking;
@end

@class QuoteTableViewCell;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, AddingSymbolViewControllerDelegate, NetworkControllerProtocol> 
{
    QuoteTableViewCell *quoteTableCell;
    UITableView *tableViewOutlet;
    UIView *tableHeaderView;
    
    UIButton *lastButton;
    UIButton *bidAskHighLowButton;
    UILabel *symbolLabel;
    
    NSString *watchlistName;
    
    id <RootViewControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, strong) IBOutlet QuoteTableViewCell *quoteTableCell;
@property (nonatomic, strong) IBOutlet UITableView *tableViewOutlet;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;

@property (nonatomic, strong) IBOutlet UIButton *lastButton;
@property (nonatomic, strong) IBOutlet UIButton *bidAskHighLowButton;
@property (nonatomic, strong) IBOutlet UILabel *symbolLabel;

@property (nonatomic, copy) NSString *watchlistName;

@property (nonatomic, unsafe_unretained) id <RootViewControllerDelegate> delegate;

// designated initializer
- (id)initWithWatchlist:(NSString *)watchlistName;

- (IBAction)headerButtonClicked:(UIButton *)sender;

@end
