//
//  RootViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "RootViewController.h"
#import "NetworkController.h"
#import "QuoteDetailViewController.h"
#import "SymbolStorage.h"
#import "QuoteTableViewCell.h"
#import "AddingSymbolViewController.h"

typedef enum {
    RowInPickerNone,
    RowInPickerLast,
    RowInPickerLastPercent,
    RowInPickerBidAsk,
    RowInPickerHighLow
} RowInPicker;

@interface RootViewController ()
{
    NSString *titleOfButtonPressed; // used to know what title button pressed
    RowInPicker rowThatUserHasChoosen; // in picker
    NSMutableArray *watchlistArray;
    
    UIBarButtonItem *editButton;
    UIBarButtonItem *addNewSymbolButton;
    
    QuoteDetailViewController *quoteDetailViewController;
    
    UIAlertView *sameNameAlert;
    
    NSString *editButtonText;
    NSString *doneButtonText;
    NSString *addButtonText;
    NSString *sameNameAlertTitle;
    NSString *sameNameAlertMessage;
    NSString *sameNameAlertOkButtonText;
    NSString *lastButtonText;
    NSString *bidButtonText;
    NSString *askButtonText;
    NSString *highButtonText;
    NSString *lowButtonText;
    NSString *cannotLoadCellMessage;
    
    BOOL isHeaderFirstButtonLast;
    BOOL isHeaderSecondButtonBidAsk;
}
@property (nonatomic, strong) NetworkController *networkController;
@property (nonatomic, copy) NSString *titleOfButtonPressed;
@property (nonatomic, assign) RowInPicker rowThatUserHasChoosen;
@property (nonatomic, strong) NSMutableArray *watchlistArray;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *addNewSymbolButton;
@property (nonatomic, strong) UIAlertView *sameNameAlert;

@property (nonatomic, copy) NSString *editButtonText;
@property (nonatomic, copy) NSString *doneButtonText;
@property (nonatomic, copy) NSString *addButtonText;
@property (nonatomic, copy) NSString *sameNameAlertTitle;
@property (nonatomic, copy) NSString *sameNameAlertMessage;
@property (nonatomic, copy) NSString *sameNameAlertOkButtonText;
@property (nonatomic, copy) NSString *lastButtonText;
@property (nonatomic, copy) NSString *bidButtonText;
@property (nonatomic, copy) NSString *askButtonText;
@property (nonatomic, copy) NSString *highButtonText;
@property (nonatomic, copy) NSString *lowButtonText;
@property (nonatomic, copy) NSString *cannotLoadCellMessage;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)setBidAskHighLowButtonTitleTo:(NSString *)left and:(NSString *)right;
- (void)configureSelf;
- (void)localize;
- (void)createAndConfigureButtons;
- (void)createAndConfigureNetworkController;
- (void)loadWatchlistFromUserDefaults;
- (void)subscribeToInstrumentsInWatchlistAndStartMonitoring;
@end

@implementation RootViewController

@synthesize quoteTableCell;
@synthesize tableViewOutlet;
@synthesize tableHeaderView;
@synthesize networkController;

@synthesize lastButton;
@synthesize bidAskHighLowButton;
@synthesize symbolLabel;

@synthesize watchlistName;

@synthesize delegate;

@synthesize titleOfButtonPressed;
@synthesize rowThatUserHasChoosen;
@synthesize watchlistArray;
@synthesize editButton;
@synthesize addNewSymbolButton;
@synthesize sameNameAlert;

@synthesize editButtonText, doneButtonText, addButtonText, sameNameAlertTitle, sameNameAlertMessage, sameNameAlertOkButtonText;
@synthesize lastButtonText, bidButtonText, askButtonText, highButtonText, lowButtonText, cannotLoadCellMessage;

#pragma mark - Object Livecycle

- (void)dealloc
{
    [self.networkController stopEventMonitor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    // for case if QuoteDetailViewController poped from NavigationController
    // QDVC is released now, we don't want to resend messages to it
    quoteDetailViewController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureSelf];
    [self localize];
    [self createAndConfigureButtons];
    [self createAndConfigureNetworkController];
    [self loadWatchlistFromUserDefaults];
    [self subscribeToInstrumentsInWatchlistAndStartMonitoring];
}

- (void)viewDidUnload
{
    [self setQuoteTableCell:nil];
    [self setTableViewOutlet:nil];
    [self setTableHeaderView:nil];
    [super viewDidUnload];
    self.networkController = nil;
    self.titleOfButtonPressed = nil;
    self.editButton = nil;
    self.addNewSymbolButton = nil;
    self.sameNameAlert = nil;
    self.symbolLabel = nil;
    
    self.editButtonText = nil;
    self.doneButtonText = nil;
    self.addButtonText = nil;
    self.sameNameAlertTitle = nil;
    self.sameNameAlertMessage = nil;
    self.sameNameAlertOkButtonText = nil;
    self.lastButtonText = nil;
    self.bidButtonText = nil;
    self.askButtonText = nil;
    self.highButtonText = nil;
    self.lowButtonText = nil;
    self.cannotLoadCellMessage = nil;
}


- (UIAlertView *)sameNameAlert
{
    if (!sameNameAlert) {
        sameNameAlert = [[UIAlertView alloc] initWithTitle:self.sameNameAlertTitle 
                                                   message:self.sameNameAlertMessage
                                                  delegate:self 
                                         cancelButtonTitle:nil 
                                         otherButtonTitles:self.sameNameAlertOkButtonText, nil];
    }
    return sameNameAlert;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([@"doneButtonPressedAnimation" isEqual:animationID]) {
        [self.tableView reloadData];
    }
}


- (void)changeAllCellsToShowWithSelector:(SEL)methodToSend
{
    for (int i = 0; i < [self.watchlistArray count]; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        
        [cell performSelector:methodToSend];
    }
}

- (void)removeAllInformationAboutCellsExceptName
{
    for (int i = 0; i < [self.watchlistArray count]; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        QuoteTableViewCell *currentCell = (QuoteTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
        [currentCell enterEditingMode];
    }
}

#pragma mark - Buttons

- (void)setBidAskHighLowButtonTitleTo:(NSString *)left and:(NSString *)right
{
    const int spacesInButton = 19;
    const int spacesNumberBetweenLeftAndRight = spacesInButton - [left length] - [right length];
    NSMutableString *resultString = [NSMutableString stringWithFormat:@""];
    for (int i = 0; i < spacesNumberBetweenLeftAndRight; i++) {
        [resultString appendFormat:@" "];
    }
    
    [resultString insertString:left atIndex:0];
    [resultString appendString:right];
    
    [self.bidAskHighLowButton setTitle:resultString forState:UIControlStateNormal];
}

- (IBAction)headerButtonClicked:(UIButton *)sender
{
    SEL methodToSend = nil;
    
    if ([sender isEqual:self.lastButton]) {
        // Last/Last%
        isHeaderFirstButtonLast = !isHeaderFirstButtonLast;
        
        if (isHeaderFirstButtonLast) {
            [self.lastButton setTitle:self.lastButtonText
                             forState:UIControlStateNormal];
            methodToSend = @selector(showLast);
        } else {
            NSString *lastPercentString = [self.lastButtonText stringByAppendingFormat:@" %%"];
            [self.lastButton setTitle:lastPercentString
                             forState:UIControlStateNormal];
            methodToSend = @selector(showLastPercent);
        }
    } else if ([sender isEqual:self.bidAskHighLowButton]) {
        // bidAsk/highLow
        isHeaderSecondButtonBidAsk = !isHeaderSecondButtonBidAsk;
        
        if (isHeaderSecondButtonBidAsk) {
            [self setBidAskHighLowButtonTitleTo:self.bidButtonText
                                            and:self.askButtonText];
            methodToSend = @selector(showHighLow);
        } else {
            [self setBidAskHighLowButtonTitleTo:self.highButtonText
                                            and:self.lowButtonText];
            methodToSend = @selector(showBidAsk);
        }
    }
    
    [self changeAllCellsToShowWithSelector:methodToSend];
    [self.tableView reloadData];
}

- (void)editButtonPressed
{
    if (self.editing) {
        // Done button pressed
        self.lastButton.enabled = YES;
        self.bidAskHighLowButton.enabled = YES;
        
        [UIView beginAnimations:@"doneButtonPressedAnimation" context:NULL];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        self.editing = NO;
        [UIView commitAnimations];
        
        self.editButton.title = self.editButtonText;
        self.editButton.style = UIBarButtonItemStylePlain;
        self.lastButton.hidden = NO;
        self.bidAskHighLowButton.hidden = NO;
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.editButton;
        
        [self.networkController startEventMonitor];
        
    } else {
        // edit button pressed
        [self.networkController stopEventMonitor];
        
        [self removeAllInformationAboutCellsExceptName];
        
        self.editing = NO;
        self.lastButton.enabled = NO;
        self.bidAskHighLowButton.enabled = NO;
        self.lastButton.hidden = YES;
        self.bidAskHighLowButton.hidden = YES;
        
        [UIView beginAnimations:@"editButtonPressedAnimation" context:NULL];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        self.editing = YES;
        [UIView commitAnimations];
        
        self.editButton.title = self.doneButtonText;
        self.editButton.style = UIBarButtonItemStyleDone;
        
        self.navigationItem.leftBarButtonItem = self.editButton;
        self.navigationItem.rightBarButtonItem = self.addNewSymbolButton;
    }
}

- (void)addNewSymbolButtonPressed
{
    AddingSymbolViewController *asvc = [[AddingSymbolViewController alloc] init];
    asvc.delegate = self;
    [self.navigationController pushViewController:asvc animated:YES];
}

#pragma mark - initialization

- (id)initWithWatchlist:(NSString *)newWatchlist
{
    if (self = [super initWithNibName:@"RootViewController" bundle:nil]) {
        self.watchlistName = newWatchlist;
        isHeaderFirstButtonLast = YES;
        isHeaderSecondButtonBidAsk = YES;
    }
    
    return self;
}

- (id)init
{
    // default watchlist is "My Faves"
    return [self initWithWatchlist:@"My Faves"];
}

# pragma mark - AddingSymbolViewController delegate methods

- (void)newSymbolWasAdded:(NSString *)symbol withExchange:(NSString *)exchange
{
    BOOL thereIsSuchSymbolInTheTable = NO;
    for (NSDictionary *instrument in self.watchlistArray) {
        if ([[instrument objectForKey:@"symbol"] caseInsensitiveCompare:symbol] == NSOrderedSame) {
            thereIsSuchSymbolInTheTable = YES;
        }
    }
    
    if (thereIsSuchSymbolInTheTable) {
        [self.sameNameAlert show];
    } else {
        NSDictionary *instrument = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"symbol", exchange, @"exchange", nil];
    
        [self.watchlistArray addObject:instrument];
        [self.tableView reloadData];
        [self.delegate watchlistInRootViewControllerHasChanged:self.watchlistArray];
    
        [self.networkController subscribeToInstrumentWithName:symbol exchange:exchange];
        
        [self removeAllInformationAboutCellsExceptName];
    }
}

#pragma mark - Network Controller Protocol methods

- (NSIndexPath *)pathForCellWithName:(NSString *)name
{
    NSIndexPath *pathToReturn = nil;
    
    NSInteger index = -1;
    for (int i = 0; i <[self.watchlistArray count]; i++) {
        if (NSOrderedSame == [name caseInsensitiveCompare:[[self.watchlistArray objectAtIndex:i] objectForKey:@"symbol"]]) {
            index = i;
        }
    }
    
    if (index != -1) {
        // we have cell with that name
        pathToReturn = [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    return pathToReturn;
}

- (void)reloadCellWithName:(NSString *)name
{
    NSIndexPath *path = [self pathForCellWithName:name];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateDataForNames:(NSSet *)namesToUpdate
{
    SymbolStorage *symbol = quoteDetailViewController.currentSymbol;

    for (NSString *name in namesToUpdate) {
        [self reloadCellWithName:name];
        if ([symbol.symbolShortName caseInsensitiveCompare:name] == NSOrderedSame) {
            symbol = [[self.networkController.subsctiptionSet objectForKey:name] objectForKey:@"symbol"];
        }
    }

    [quoteDetailViewController updateViewWithSymbol:symbol];
}

- (void)unableToSubscribeOnInstrumentWithName:(NSString *)name andExchange:(NSString *)exchange
{
    // >>>> - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    // method use "error" key to know, that cell can't be loaded
    // it doesn't modify watchlist in database (don't send watchlistInRootViewControllerHasChanged method)
    NSIndexPath *path = [self pathForCellWithName:name];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.watchlistArray objectAtIndex:path.row]];
    [dict setObject:@"error" forKey:@"error"];
    [self.watchlistArray replaceObjectAtIndex:path.row withObject:dict];
    
    [self.tableView reloadData];
}

- (void)errorOccured
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"Cannot Connect to Server" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.delegate rootViewControllerFinishedWorking];
}

#pragma mark - NetworkController subsctiptionSet getters

- (SymbolStorage *)objectForIndexPath:(NSIndexPath *)indexPath
{
    NSString *aKey = [[[self.watchlistArray objectAtIndex:indexPath.row] objectForKey:@"symbol"] lowercaseString];

    SymbolStorage *anObject = [[self.networkController.subsctiptionSet objectForKey:aKey] objectForKey:@"symbol"];
    
    return anObject;    
}

-(NSIndexPath *)indexPathForSymbol:(SymbolStorage *)symbol
{
    NSString *aKey = [symbol.symbolShortName  lowercaseString];
    NSArray *keys = [self.networkController.subsctiptionSet allKeys];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[keys indexOfObject:aKey]
                                                inSection:0];
    return indexPath;
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  return  self.tableHeaderView;
}



#pragma mark - Table view delegate                                       

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.watchlistArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    QuoteTableViewCell *cell = (QuoteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {

        [[NSBundle mainBundle] loadNibNamed:@"QuoteTableViewCell" owner:self options:nil];
        cell = quoteTableCell;
        NSString *name = [[self.watchlistArray objectAtIndex:indexPath.row] objectForKey:@"symbol"];
        [cell updateSymbol:[self objectForIndexPath:indexPath] 
                  withName:name];

        self.quoteTableCell = nil;
    }

    // Configure the cell.
    
    // can be added to dictionary in 
    // - (void)unableToSubsribeOnInstrumentWithName:(NSString *)name andExchange:(NSString *)exchange
    // "error" means that we can't load cell, so lets show error label
    if ([[self.watchlistArray objectAtIndex:indexPath.row] objectForKey:@"error"]) {
        // error
        if (![cell isError]) {
            NSString *cellName = [[self.watchlistArray objectAtIndex:indexPath.row] objectForKey:@"symbol"];
            NSString *message = [self.cannotLoadCellMessage stringByAppendingFormat:@" %@", cellName];
            [cell showErrorLabelWithMessage:message];
        }
    } else {
        if (!cell.symbolPrice.text) {
            // if cell is loading
            [cell showLoadingAndHideAllSymbolInformation];
        } else {
            if (self.editing) {
                // editing
                [cell enterEditingMode];
            } else if ([cell isCellLoading]) {
                //all is ok
                [cell hideLoading];
                
                if (isHeaderFirstButtonLast) {
                    [cell showLast];
                } else {
                    [cell showLastPercent];
                }
                
                if (isHeaderSecondButtonBidAsk) {
                    [cell showBidAsk];
                } else {
                    [cell showHighLow];
                }
            }
        }
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.watchlistArray objectAtIndex:indexPath.row] objectForKey:@"error"]) {
        // error. can't open it
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    } else {
        QuoteDetailViewController *qdvc = [[QuoteDetailViewController alloc] init];
        quoteDetailViewController = qdvc;
        
        SymbolStorage *selectedSymbol = [self objectForIndexPath:indexPath];
        qdvc.currentSymbol = selectedSymbol;
        
        [self.navigationController pushViewController:qdvc animated:YES];
    }
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.networkController unsubscribeToInstrumentWithName:[[self.watchlistArray objectAtIndex:indexPath.row] objectForKey:@"symbol"]];        

        [self.watchlistArray removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.delegate watchlistInRootViewControllerHasChanged:self.watchlistArray];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle style = UITableViewCellEditingStyleDelete;
    
    QuoteTableViewCell *cell = (QuoteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isCellLoading]) {
        // still loading cell
        style = UITableViewCellEditingStyleNone;
    }
    return style;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
                                                  toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger source = sourceIndexPath.row;
    NSInteger destination = destinationIndexPath.row;
    id objectToMove = [self.watchlistArray objectAtIndex:source];
    
    if (source > destination) {
        source++;
    } else {
        destination++;
    }
    [self.watchlistArray insertObject:objectToMove atIndex:destination];
    [self.watchlistArray removeObjectAtIndex:source];
    [self.delegate watchlistInRootViewControllerHasChanged:self.watchlistArray];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // user swipes out a delete button
    // don't want to be in editing mode, all cell's info would be clean
    self.editing = NO;
}

#pragma mark - Supporting methods

- (void)configureSelf
{
    self.title = self.watchlistName;
    self.tableView.separatorColor = [UIColor darkGrayColor];
}

- (void)localize
{
    self.editButtonText = NSLocalizedString(@"Edit", nil);
    self.doneButtonText = NSLocalizedString(@"Done", nil);
    self.addButtonText = NSLocalizedString(@"Add", nil);
    self.sameNameAlertTitle = NSLocalizedString(@"Error", nil);
    self.sameNameAlertMessage = NSLocalizedString(@"Name already exists", nil);
    self.sameNameAlertOkButtonText = NSLocalizedString(@"OK", nil);
    self.lastButtonText = NSLocalizedString(@"Last", nil);
    self.bidButtonText = NSLocalizedString(@"Bid", nil);
    self.askButtonText = NSLocalizedString(@"Ask", nil);
    self.highButtonText = NSLocalizedString(@"High", nil);
    self.lowButtonText = NSLocalizedString(@"Low", nil);
    self.cannotLoadCellMessage = NSLocalizedString(@"Cannot load", nil);
    
    [self.lastButton setTitle:self.lastButtonText forState:UIControlStateNormal];
    [self setBidAskHighLowButtonTitleTo:self.bidButtonText
                                    and:self.askButtonText];
    self.symbolLabel.text = NSLocalizedString(@"Symbol", nil);
}

- (void)createAndConfigureButtons
{
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:self.editButtonText
                                                       style:UIBarButtonItemStylePlain 
                                                      target:self
                                                      action:@selector(editButtonPressed)];
    self.editButton.possibleTitles = [NSSet setWithObjects:self.editButtonText, self.doneButtonText, nil];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    self.addNewSymbolButton = [[UIBarButtonItem alloc] initWithTitle:self.addButtonText
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(addNewSymbolButtonPressed)];
}

- (void)createAndConfigureNetworkController
{
    self.networkController = [[NetworkController alloc] init];
    self.networkController.delegate = self;
}

- (void)loadWatchlistFromUserDefaults
{
    NSUserDefaults *standartUserDefaults = [[NSUserDefaults alloc] init];
    self.watchlistArray = [NSMutableArray arrayWithArray:[[standartUserDefaults objectForKey:@"watchlists" ] objectForKey:self.watchlistName]];
}

- (void)subscribeToInstrumentsInWatchlistAndStartMonitoring
{
    for (NSDictionary *instrument in self.watchlistArray) {
        [self.networkController subscribeToInstrumentWithName:[instrument objectForKey:@"symbol"]
                                                     exchange:[instrument objectForKey:@"exchange"]];
    }
    [self.networkController startEventMonitor];
}

@end
