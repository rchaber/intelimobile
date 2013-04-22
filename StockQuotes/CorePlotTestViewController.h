//
//  CorePlotTestViewController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/28/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CorePlotTestViewController : UIViewController <CPTPlotDataSource>
{
    CPTXYGraph *graph;
    
	NSMutableArray *dataForPlot;
}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot;

@end
