//
//  ConfigureStudyViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 10/21/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureStudyValueCell.h"

@class ConfigureStudyViewController;

@protocol ConfigureStudyViewControllerDelegate <NSObject>
@optional
- (void)configureStudyViewControllerpopedUpForName:(NSString *)name withParameters:(NSDictionary *)parameters;
@end

@class ConfigureStudyValueCell;
@class ConfigureStudyButtonCell;
@class ConfigureStudyColorCell;

@interface ConfigureStudyViewController : UITableViewController <ConfigureStudyValueCellDelegate>
{
    ConfigureStudyValueCell *configureStudyValueCell;
    ConfigureStudyButtonCell *configureStudyButtonCell;
    ConfigureStudyColorCell *configureStudyColorCell;
    
    id <ConfigureStudyViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) IBOutlet ConfigureStudyValueCell *configureStudyValueCell;
@property (nonatomic, strong) IBOutlet ConfigureStudyButtonCell *configureStudyButtonCell;
@property (nonatomic, strong) IBOutlet ConfigureStudyColorCell *configureStudyColorCell;

@property (nonatomic, unsafe_unretained) id <ConfigureStudyViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *oldOptions;

- (id)initWithNameOfPlot:(NSString *)name andOptions:(NSDictionary *)options;

@end
