//
//  NetworkControllerProtocol.h
//  StockQuotes
//
//  Created by Edward Khorkov on 9/14/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SymbolStorage.h"

@protocol NetworkControllerProtocol <NSObject>

- (void)updateDataForNames:(NSSet *)namesToUpdate;
- (void)unableToSubscribeOnInstrumentWithName:(NSString *)name andExchange:(NSString *)exchange;
- (void)errorOccured;

@end
