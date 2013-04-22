//
//  StochasticsProtocol.h
//  Indicators
//
//  Created by Edward Khorkov on 26.10.11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import "InputDataOrder.h"

@protocol StochasticsProtocol <NSObject>

-(NSArray *)calculateForDataArray:(NSArray *)data
                forHighValueNamed:(NSString *)highValName
                currentValueNamed:(NSString *)currentValName
                    lowValueNamed:(NSString *)lowValName
                          ordered:(enum InputDataOrder)order;
@end
