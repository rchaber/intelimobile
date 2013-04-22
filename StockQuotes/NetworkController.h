//
//  NetworkController.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SymbolStorage;
@class QuoteDetailViewController;
@protocol NetworkControllerProtocol;

@interface NetworkController : NSObject
{
    NSMutableDictionary *subsctiptionSet;
}
@property (nonatomic, strong) NSMutableDictionary *subsctiptionSet;
@property (nonatomic, unsafe_unretained) id<NetworkControllerProtocol> delegate;

// add instrument to eventMonitor
// object is for any information you want attach to instrument
-(void)subscribeToInstrumentWithName:(NSString *)name exchange:(NSString *)exchange;
-(void)unsubscribeToInstrumentWithName:(NSString *)name;

-(void)startEventMonitor;
-(void)stopEventMonitor;

-(void)addNameToUpdate:(NSString *)name;

-(BOOL)isActive;

@end

