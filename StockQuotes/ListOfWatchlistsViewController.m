//
//  ListOfWatchlistsViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/21/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "ListOfWatchlistsViewController.h"
#import "RootViewController.h"
#import "XMLReader.h"

@interface ListOfWatchlistsViewController()
{
    NSMutableArray *watchlistsNames;
    
    RootViewController *rootViewController;
    UIBarButtonItem *editButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *nowWatchingButton;
    
    UIAlertView *sameNameAlert;
    
    NSString *titleOfCellThatWasChangedWithLongPress;
    
    NSString *editButtonText;
    NSString *doneButtonText;
    NSString *cancelButtonText;
    NSString *sameNameAlertTitle;
    NSString *sameNameAlertMessage;
    NSString *sameNameAlertOkButtonText;
    NSString *nowWatchingButtonText;
}
@property (nonatomic, strong) NSMutableArray *watchlistsNames;

@property (nonatomic, strong) RootViewController *rootViewController;
@property (nonatomic, strong) UIAlertView *sameNameAlert;
@property (nonatomic, copy) NSString *titleOfCellThatWasChangedWithLongPress;

@property (nonatomic, copy) NSString *editButtonText;
@property (nonatomic, copy) NSString *doneButtonText;
@property (nonatomic, copy) NSString *cancelButtonText;
@property (nonatomic, copy) NSString *sameNameAlertTitle;
@property (nonatomic, copy) NSString *sameNameAlertMessage;
@property (nonatomic, copy) NSString *sameNameAlertOkButtonText;
@property (nonatomic, copy) NSString *nowWatchingButtonText;

@end

@implementation ListOfWatchlistsViewController

@synthesize watchlists;

@synthesize tableHeaderView;
@synthesize tableHeaderViewLabel;
@synthesize tableHeaderViewTextField;
@synthesize tableHeaderViewButton;

@synthesize checkmarkView;
@synthesize textFieldForEditingTableRow;

@synthesize delegate = _delegate;

@synthesize watchlistsNames;

@synthesize rootViewController;
@synthesize sameNameAlert;
@synthesize titleOfCellThatWasChangedWithLongPress;

@synthesize editButtonText, doneButtonText, cancelButtonText, sameNameAlertTitle, sameNameAlertMessage, sameNameAlertOkButtonText, nowWatchingButtonText;

- (UIAlertView *)sameNameAlert
{
    if (!sameNameAlert) {
        sameNameAlert = [[UIAlertView alloc] initWithTitle:sameNameAlertTitle 
                                                   message:sameNameAlertMessage 
                                                  delegate:self 
                                         cancelButtonTitle:nil 
                                         otherButtonTitles:self.sameNameAlertOkButtonText, nil];
    }
    return sameNameAlert;
}

#pragma mark - Gesture recognizers

-(BOOL)textFieldShouldReturn:(UITextField *)tField
{
    BOOL answer = NO;
    
    if ([tField isEqual:self.textFieldForEditingTableRow] && ![tField.text isEqual:@""]) {
        BOOL suchKeyAppears = NO;
        for (NSString *key in self.watchlistsNames) {
            if ([key isEqual:tField.text]) {
                suchKeyAppears = YES;
            }
        }
        if (suchKeyAppears && ![self.titleOfCellThatWasChangedWithLongPress isEqual:tField.text]) {
            [self.sameNameAlert show];
        } else {
        
            answer = YES;
            [self.textFieldForEditingTableRow resignFirstResponder];
            self.textFieldForEditingTableRow.hidden = YES;
        
            if (![tField.text isEqual:self.titleOfCellThatWasChangedWithLongPress]) {
                // if new title doesn't equal old one
                
                if ([self.titleOfCellThatWasChangedWithLongPress isEqual:self.rootViewController.watchlistName]) {
                    // it is active watchlist
                    self.rootViewController.watchlistName = tField.text;
                    self.rootViewController.title = tField.text;
                }
                [self.watchlists setObject:[self.watchlists objectForKey:self.titleOfCellThatWasChangedWithLongPress] 
                                    forKey:tField.text];
                [self.watchlists removeObjectForKey:self.titleOfCellThatWasChangedWithLongPress];
                
                NSInteger index = [self.watchlistsNames indexOfObject:self.titleOfCellThatWasChangedWithLongPress];
                [self.watchlistsNames replaceObjectAtIndex:index
                                                withObject:tField.text];
                
                [self.tableView reloadData];
                
                NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
                [standartUserDefaults setObject:self.watchlists forKey:@"watchlists"];
                [standartUserDefaults synchronize];
            }
       
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }
    }
    return answer;
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan && !self.editing)
	{
		// get affected cell
		UITableViewCell *cell = (UITableViewCell *)[gesture view];

        self.textFieldForEditingTableRow.hidden = NO;
        // size.height - 1 to show table view's separator (white line between cells)
        self.textFieldForEditingTableRow.frame = CGRectMake (cell.textLabel.frame.origin.x, cell.frame.origin.y, 
                                                             cell.frame.size.width, cell.frame.size.height - 1);
        self.textFieldForEditingTableRow.text = cell.textLabel.text;
        self.textFieldForEditingTableRow.textColor = cell.textLabel.textColor;
        
		[self.textFieldForEditingTableRow becomeFirstResponder];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
        self.titleOfCellThatWasChangedWithLongPress = cell.textLabel.text;
	}
}

#pragma mark - Buttons

- (void)editButtonPressed
{
    if (self.editing) {
        // Done button pressed
        if (![self.tableHeaderViewTextField.text isEqual:@""]) {
            BOOL wasSuchName = NO;
            for (NSString *name in [self.watchlists allKeys]) {
                if ([name isEqualToString:self.tableHeaderViewTextField.text]) {
                    wasSuchName = YES;
                }
            }
            
            if (!wasSuchName) {
                [self.watchlists setObject:[NSArray array] forKey:self.tableHeaderViewTextField.text];
                [self.watchlistsNames addObject:self.tableHeaderViewTextField.text];
                self.tableHeaderViewTextField.text = @"";
            } else {
                [self.sameNameAlert show];
            }
        }
        
        [UIView beginAnimations:@"doneButtonPressedAnimation" context:NULL];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        self.editing = NO;
        [UIView commitAnimations];
        
        editButton.title = editButtonText;
        editButton.style = UIBarButtonItemStylePlain;
        
        self.tableHeaderViewLabel.hidden = NO;
        self.tableHeaderViewButton.hidden = YES;
        self.tableHeaderViewTextField.hidden = YES;
        
        self.navigationItem.leftBarButtonItem = editButton;
        self.navigationItem.rightBarButtonItem = nowWatchingButton;
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:self.watchlists forKey:@"watchlists"];
        [standardUserDefaults synchronize];
        
        self.tableHeaderViewTextField.text = @"";
    } else {
        // edit button pressed
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.editing = YES;
        [UIView commitAnimations];
        
        editButton.title = doneButtonText;
        editButton.style = UIBarButtonItemStyleDone;
        
        self.tableHeaderViewLabel.hidden = YES;
        self.tableHeaderViewButton.hidden = NO;
        self.tableHeaderViewTextField.hidden = NO;
        
        
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = editButton;
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([@"cancelButtonPressedAnimation" isEqual:animationID]) {
        NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
        self.watchlists = [NSMutableDictionary dictionaryWithDictionary:[standartUserDefaults objectForKey:@"watchlists"]];
        [self.tableView reloadData];
    } else if ([@"doneButtonPressedAnimation" isEqual:animationID]) {
        [self.tableView reloadData];
    }
}

- (void)cancelButtonPressed
{
    if (self.editing) {
        [UIView beginAnimations:@"cancelButtonPressedAnimation" context:NULL];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        self.editing = NO;
        [UIView commitAnimations];
        
        editButton.title = editButtonText;
        editButton.style = UIBarButtonItemStylePlain;
        
        self.tableHeaderViewLabel.hidden = NO;
        self.tableHeaderViewButton.hidden = YES;
        self.tableHeaderViewTextField.hidden = YES;
        
        self.navigationItem.leftBarButtonItem = editButton;
        self.navigationItem.rightBarButtonItem = nowWatchingButton;
    }
}

- (void)nowWatchingButtonPressed
{
    [self.navigationController pushViewController:self.rootViewController animated:YES];
}

- (IBAction)plusButtonPressed:(id)sender
{
    if (![self.tableHeaderViewTextField.text isEqual:@""]) {
        BOOL wasSuchName = NO;
        for (NSString *name in [self.watchlists allKeys]) {
            if ([name isEqualToString:self.tableHeaderViewTextField.text]) {
                wasSuchName = YES;
            }
        }
    
        if (!wasSuchName) {
            [self.watchlists setObject:[NSArray array] forKey:self.tableHeaderViewTextField.text];
            [self.watchlistsNames addObject:self.tableHeaderViewTextField.text];
            [self.tableView reloadData];
            self.tableHeaderViewTextField.text = @"";
        } else {
            [self.sameNameAlert show];
        }
    }
}

#pragma mark - View lifecycle

- (void)localize
{
    self.title = NSLocalizedString(@"Watchlists", nil);
    self.tableHeaderViewLabel.text = NSLocalizedString(@"Click and hold a watchlist to rename it", nil);
    self.tableHeaderViewTextField.placeholder = NSLocalizedString(@"Enter New Watchlist Name", nil);
    self.editButtonText = NSLocalizedString(@"Edit", nil);
    self.doneButtonText = NSLocalizedString(@"Done", nil);
    self.cancelButtonText = NSLocalizedString(@"Cancel", nil);
    self.sameNameAlertTitle = NSLocalizedString(@"Error", nil);
    self.sameNameAlertMessage = NSLocalizedString(@"Name already exists", nil);
    self.sameNameAlertOkButtonText = NSLocalizedString(@"OK", nil);
    self.nowWatchingButtonText = NSLocalizedString(@"Now watching", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // if view is load for first time - push rootView
    static BOOL wasViewLoaded = NO;
    if (!wasViewLoaded) {
        self.rootViewController = [[RootViewController alloc] init];
        self.rootViewController.delegate = self;
        [self.navigationController pushViewController:self.rootViewController animated:NO];
    }

    [self localize];
    
    NSString *xmlString = @"<userinfo username=\"sancho\" real_name=\"Sancho Panza\"><preferences><item key=\"ask_on_close\" value=\"true\"/></preferences> <watchlists><watchlist name=\"My Faves\"> <instruments><instrument exchange=\"NASDAQ\" symbol=\"GOOG\" description=\"\"/> <instrument exchange=\"NASDAQ\" symbol=\"MSFT\" description=\"\"/> <instrument exchange=\"NYSE\" symbol=\"F\" description=\"\"/></instruments> </watchlist><watchlist name=\"Mom\'s assets\"> <instruments><instrument exchange=\"NASDAQ\" symbol=\"EBAY\" description=\"\"/> </instruments></watchlist></watchlists> </userinfo>";
    
    // Parsing XML and saving to UserDefaults
    NSError *parseError = nil;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:xmlString error:&parseError];
    NSArray *arrayOfWatchlists = [NSArray arrayWithArray:[[[xmlDictionary objectForKey:@"userinfo"] objectForKey:@"watchlists"] objectForKey:@"watchlist"]];
    
    watchlists = [[NSMutableDictionary alloc] init];
    for (NSDictionary *wlist in arrayOfWatchlists) {
        // if contains more than one element => array, if only one => than element, so we make array with it
        if ([[[wlist objectForKey:@"instruments"] objectForKey:@"instrument"] isKindOfClass:[NSArray class]]) {
            [self.watchlists setValue:[[wlist objectForKey:@"instruments"] objectForKey:@"instrument"]
                           forKey:[wlist objectForKey:@"name"]];
        } else {
            [self.watchlists setValue:[NSArray arrayWithObject:[[wlist objectForKey:@"instruments"] objectForKey:@"instrument"]]
                               forKey:[wlist objectForKey:@"name"]];
        }
    }

    self.watchlistsNames = [NSMutableArray arrayWithArray:[self.watchlists allKeys]];
    
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    [standartUserDefaults setObject:self.watchlists forKey:@"watchlists"];

    
    // Buttons 
    nowWatchingButton = [[UIBarButtonItem alloc] initWithTitle:self.nowWatchingButtonText 
                                                        style:UIBarButtonItemStylePlain
                                                        target:self 
                                                        action:@selector(nowWatchingButtonPressed)];
    self.navigationItem.rightBarButtonItem = nowWatchingButton;

    editButton = [[UIBarButtonItem alloc] initWithTitle:editButtonText 
                                                  style:UIBarButtonItemStylePlain
                                                 target:self 
                                                 action:@selector(editButtonPressed)];
    editButton.possibleTitles = [NSSet setWithObjects:editButtonText, 
                                                      doneButtonText, nil]  ;
    self.navigationItem.leftBarButtonItem = editButton;
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancelButtonText
                                                    style:UIBarButtonItemStylePlain
                                                   target:self 
                                                   action:@selector(cancelButtonPressed)];

    self.tableView.separatorColor = [UIColor darkGrayColor];
    
    [self.view addSubview:self.textFieldForEditingTableRow];
    self.textFieldForEditingTableRow.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.watchlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    
    UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
                                                                                                      action:@selector(longPress:)];
    [cell addGestureRecognizer:lpGestureRecognizer];
    cell.textLabel.text = [self.watchlistsNames objectAtIndex:indexPath.row];

    if ([cell.textLabel.text isEqual:self.rootViewController.watchlistName]) {
        cell.textLabel.textColor = [UIColor orangeColor];
        [cell addSubview:self.checkmarkView];
        self.checkmarkView.frame = CGRectMake(cell.frame.size.width - 50, (cell.frame.size.height - self.checkmarkView.frame.size.height)/2,
                                              self.checkmarkView.frame.size.width, self.checkmarkView.frame.size.height);
    } else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqual:self.rootViewController.watchlistName]) {
            // it is current running watchlist
            nowWatchingButton.enabled = NO;
        }
        
        [self.watchlists removeObjectForKey:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [self.watchlistsNames removeObject:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *currentCellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    if (![currentCellText isEqual:self.rootViewController.watchlistName]) {
        self.rootViewController = [[RootViewController alloc] initWithWatchlist:currentCellText];
        self.rootViewController.delegate = self;
        nowWatchingButton.enabled = YES;
    }
    [self.navigationController pushViewController:self.rootViewController animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.tableHeaderView;
}

#pragma mark - RootViewController delegate

- (void)watchlistInRootViewControllerHasChanged:(NSArray *)wlist
{
    [self.watchlists setObject:wlist forKey:self.rootViewController.watchlistName];
    
    NSUserDefaults *standartUserDefaults = [NSUserDefaults standardUserDefaults];
    [standartUserDefaults setObject:self.watchlists forKey:@"watchlists"];
    [standartUserDefaults synchronize];
}

- (void)rootViewControllerFinishedWorking
{
    [self.delegate listOfWatchlistsViewControllerFinishedWorking];
}


@end
