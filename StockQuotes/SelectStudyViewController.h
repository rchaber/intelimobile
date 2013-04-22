//
//  SelectStudyViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 10/21/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureStudyViewController.h"

@class SelectStudyViewController;
@protocol SelectStudyViewControllerDelegate <NSObject>
@optional
- (void)selectStudyViewController:(SelectStudyViewController *)controller didSelectRowWithName:(NSString *)name withOptions:(NSDictionary *)options;
@end

@interface SelectStudyViewController : UITableViewController <ConfigureStudyViewControllerDelegate>
{
    id <SelectStudyViewControllerDelegate> __unsafe_unretained delegate;
    
    NSArray *arrayOfStudies;
    NSString *cellNameToSelect;
}

@property (nonatomic, unsafe_unretained) id <SelectStudyViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *arrayOfStudies;
@property (nonatomic, copy) NSString *cellNameToSelect;
@property (nonatomic, strong) NSDictionary *optionsForCellToSelect;

@end
