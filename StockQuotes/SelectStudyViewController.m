//
//  SelectStudyViewController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 10/21/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "SelectStudyViewController.h"
#import "ConfigureStudyViewController.h"

@implementation SelectStudyViewController

@synthesize delegate;

@synthesize arrayOfStudies;
@synthesize cellNameToSelect;
@synthesize optionsForCellToSelect = _optionsForCellToSelect;

#pragma mark - Properties

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.separatorColor = [UIColor darkGrayColor];
    }
    return self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayOfStudies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.arrayOfStudies objectAtIndex:indexPath.row];
    
    UIColor *textColor; 
    UIImage *accessoryImage;
    if ([cell.textLabel.text isEqualToString:self.cellNameToSelect]) {
        textColor = [UIColor orangeColor];
        accessoryImage = [UIImage imageNamed:@"1318356909_checkmark.png"];
    } else {
        textColor = [UIColor whiteColor];
        accessoryImage = [UIImage imageNamed:@"triangle.png"];
    }
    
    cell.textLabel.textColor = textColor;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    
    if (![cell.textLabel.text isEqualToString:NSLocalizedString(@"None", nil)] ||
        [cell.textLabel.text isEqualToString:self.cellNameToSelect]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:accessoryImage];
        float imageViewWidth = imageView.frame.size.width/2;
        float imageViewHeight = imageView.frame.size.height/2;
        imageView.frame = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
    
        cell.accessoryView = imageView;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *nameOfCell = [self.arrayOfStudies objectAtIndex:indexPath.row];
    if ([nameOfCell isEqualToString:NSLocalizedString(@"None", nil)]) {
        if ([self.delegate respondsToSelector:@selector(selectStudyViewController:didSelectRowWithName:withOptions:)]) {
            NSString *name = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            [self.delegate selectStudyViewController:self didSelectRowWithName:name withOptions:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];

    } 
    else {
        id options = nil;
        if ([[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:self.cellNameToSelect]) {
            options = self.optionsForCellToSelect;
        }
        ConfigureStudyViewController *confCon = [[ConfigureStudyViewController alloc] initWithNameOfPlot:nameOfCell andOptions:options];
        confCon.delegate = self;
        [self.navigationController pushViewController:confCon animated:YES];
    }
}

#pragma mark - ConfigureStudyViewController delegate

- (void)configureStudyViewControllerpopedUpForName:(NSString *)name withParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *param = nil;
    if (parameters) {
        param = [NSMutableDictionary dictionaryWithDictionary:parameters];
        
        NSMutableDictionary *dictionaryWithColors = [NSMutableDictionary dictionary];
        for (NSString *key in [param objectForKey:@"color"]) {
            UIColor *color = [[param objectForKey:@"color"] objectForKey:key];
            
            CGFloat red, green, blue, alpha;
            
            int numComponents = CGColorGetNumberOfComponents(color.CGColor);
            if (numComponents == 4)
            {
                const CGFloat *components = CGColorGetComponents(color.CGColor);
                red = components[0];
                green = components[1];
                blue = components[2];
                alpha = components[3];
            }
        
            NSDictionary *oneColor = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSString stringWithFormat:@"%f", red], @"red",
                                      [NSString stringWithFormat:@"%f", green], @"green",
                                      [NSString stringWithFormat:@"%f", blue], @"blue",
                                      [NSString stringWithFormat:@"%f", alpha], @"alpha",
                                      nil];
            [dictionaryWithColors setObject:oneColor forKey:key];
        }
        [param setObject:dictionaryWithColors forKey:@"color"];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectStudyViewController:didSelectRowWithName:withOptions:)]) {
        [self.delegate selectStudyViewController:self didSelectRowWithName:name withOptions:param];
        }
    
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
