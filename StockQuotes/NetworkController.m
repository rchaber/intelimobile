//
//  NetworkController.m
//  StockQuotes
//
//  Created by Edward Khorkov on 9/13/11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "NetworkController.h"
#import "NetworkControllerProtocol.h"
#import "SymbolStorage.h"
#import "p9mdi_client.h"

#define TIME_INTERVAL_TO_UPDATE 0.1

static NSString *pKey_LastUpdate = @"LastUpdate";
static NSString *pKey_Price = @"Price";
static NSString *pKey_Exchange = @"SecurityExchange";
static NSString *pKey_PercentChange = @"PercentChange";
static NSString *pKey_NetChange = @"NetChange";
static NSString *pKey_BidPrice = @"BidPrice";
static NSString *pKey_BidSize = @"BidSize";
static NSString *pKey_AskPrice = @"AskPrice";
static NSString *pKey_AskSize = @"AskSize";
static NSString *pKey_OpenPrice = @"OpenPrice";
static NSString *pKey_HighPrice = @"MaxPrice";
static NSString *pKey_LowPrice = @"MinPrice";
static NSString *pKey_Symbol = @"Symbol";
static NSString *pKey_SymbolLong = @"SecurityDesc";
static NSString *pKey_PrevClosingPrice = @"PreviousClosingPrice";
static NSString *PKey_TradeVolume = @"TradeVolume";

NetworkController* networkController;
static dispatch_queue_t background_network_thread;

dispatch_queue_t background_network_queue()
{
    if (background_network_thread == NULL)
    {
        background_network_thread = dispatch_queue_create("network.backgroundrequests", 0);
    }
    return background_network_thread;
}

void cleanup_network_queue()
{
	if (background_network_thread != NULL)
	{
        dispatch_release(background_network_thread);
        background_network_thread = NULL;
	}
}

void OnInstrumentProperty(void* cookie, unsigned eventCode, const char* key, const char* value)
{
    if (!key || !value) return;

	const char* symbol = (const char*) cookie;
//	printf("OnInstrumentProperty: symbol:%s, key=%s, value=%s\r\n", symbol, key, value);
    NSString *objectSymbol = [NSString stringWithUTF8String:symbol];
    NSString *objectKey = [NSString stringWithUTF8String:key];
    NSString *objectValue = [NSString stringWithUTF8String:value];
    
     dispatch_async(dispatch_get_main_queue(), ^{ 
         
         SymbolStorage *currentSymbol = [[networkController.subsctiptionSet objectForKey:objectSymbol] objectForKey:@"symbol"];
//         NSLog(@"%@ - %@", objectKey, objectValue);
         if (currentSymbol) {
            [networkController addNameToUpdate:objectSymbol];
             
             if ([objectKey isEqualToString:pKey_Price]) {
                 currentSymbol.symbolPrice = objectValue;
             } else if([objectKey isEqualToString:pKey_PercentChange]) {
                 currentSymbol.symbolPricePercentChange = objectValue;
             } else if([objectKey isEqualToString:pKey_NetChange]) {
                 currentSymbol.symbolPriceNetChange = objectValue;
             }  else if([objectKey isEqualToString:pKey_BidPrice]) {
                 currentSymbol.symbolBidPrice = objectValue;
             }  else if([objectKey isEqualToString:pKey_BidSize]) {
                 currentSymbol.symbolBidSize = objectValue;
             }  else if([objectKey isEqualToString:pKey_AskPrice]) {
                 currentSymbol.symbolAskPrice = objectValue;
             }  else if([objectKey isEqualToString:pKey_AskSize]) {
                 currentSymbol.symbolAskSize = objectValue;
             }  else if([objectKey isEqualToString:pKey_OpenPrice]) {
                 currentSymbol.symbolOpenPrice = objectValue;
             }  else if([objectKey isEqualToString:pKey_HighPrice]) {
                 currentSymbol.symbolHighPrice = objectValue;
             }  else if([objectKey isEqualToString:pKey_LowPrice]) {
                 currentSymbol.symbolLowPrice = objectValue;
             } else if ([objectKey isEqualToString:pKey_SymbolLong]) {
                currentSymbol.symbolLongName = objectValue;
             } else if ([objectKey isEqualToString:pKey_PrevClosingPrice]) {
                 currentSymbol.symbolPrevClosingPrice = objectValue;
             } else if ([objectKey isEqualToString:PKey_TradeVolume]) {
                 currentSymbol.symbolTradeVolume = objectValue;
             }
             
             //update subscriptionSet with updated symbol storage object
             NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[networkController.subsctiptionSet objectForKey:objectSymbol]];
             [dict setObject:currentSymbol forKey:@"symbol"];
             [networkController.subsctiptionSet setObject:dict forKey:objectSymbol];
         }
     });
     
}

static int RUNNING_THREAD_NUMBER = 0;

@interface NetworkController()
{
    NSMutableSet *namesToUpdate;
    NSTimer *updateTimer;
    
    NSString *server;
    unsigned short port;
    
    BOOL isNetworkControllerActive;
    BOOL shallNetworkControllerRun;
}
@property (nonatomic, strong) NSMutableSet *namesToUpdate;
@end

@implementation NetworkController

@synthesize delegate, subsctiptionSet;
@synthesize namesToUpdate;

- (BOOL)isActive
{
    return isNetworkControllerActive;
}

//static char *c_server = "187.37.4.83";

- (id)init
{
    if (self = [super init]) {
        networkController = self;
        self.namesToUpdate = [NSMutableSet set];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        server = [[standardUserDefaults objectForKey:@"connection settings"] objectForKey:@"server"];
        port = [[[standardUserDefaults objectForKey:@"connection settings"] objectForKey:@"port"] integerValue];
        isNetworkControllerActive = NO;
    }
    
    return self;
}



#pragma mark - Lazy Instantiation
- (NSMutableDictionary *) subsctiptionSet 
{
    if (!subsctiptionSet) {
        subsctiptionSet = [[NSMutableDictionary alloc] init];
    }
    return subsctiptionSet;
}

#pragma mark Background Stuff

-(void)subscribeToInstrumentWithName:(NSString *)name exchange:(NSString *)exchange
{
    SymbolStorage *aSymbol = [[SymbolStorage alloc] init]; 
    //add empty object to the dictionary
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[exchange lowercaseString], @"exchange", 
                                                                    aSymbol, @"symbol",  
                                                                    nil];
    [self.subsctiptionSet setObject:dict forKey:[name lowercaseString]];
}

-(void)unsubscribeToInstrumentWithName:(NSString *)name
{
    [self.subsctiptionSet removeObjectForKey:[name lowercaseString]];
}

+ (void)startUpdate
{
    
}

-(void)startEventMonitor
{
    shallNetworkControllerRun = YES;
    isNetworkControllerActive = YES;
    int myNumber = ++RUNNING_THREAD_NUMBER;
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL_TO_UPDATE
                                                   target:self
                                                 selector:@selector(sendUpdateToDelegate)
                                                 userInfo:nil
                                                  repeats:YES];
    dispatch_async(background_network_queue(), ^{
        NSArray *keysToEnumerate = [self.subsctiptionSet allKeys]; 
        
        const char *c_server = [server UTF8String];
        
        struct P9MDI_CONNECTION* connection;
        int result = p9mdi_connect(c_server, port, "", "", &connection);
        NSLog(@"Result: %i myNumber: %i", result, myNumber);
        
        if (result == 0) {
            for(NSString *anInstrument in keysToEnumerate){ 
                const char *c_instrument = [anInstrument cStringUsingEncoding:NSASCIIStringEncoding];
                const char *exchange = [[[self.subsctiptionSet objectForKey:anInstrument] objectForKey:@"exchange"] UTF8String];
                  
                int result =  p9mdi_subscribe_instrument_properties(connection, exchange, c_instrument, SnapshotPlusIncremental, &OnInstrumentProperty, (void *)c_instrument, NULL);
                if (!P9_FAILED(result)) {
                    SymbolStorage *aSymbol = [[self.subsctiptionSet objectForKey:anInstrument] objectForKey:@"symbol"];
                    aSymbol.symbolShortName = [anInstrument uppercaseString];
                    [[self.subsctiptionSet objectForKey:@"instrument"] setObject:aSymbol forKey:@"symbol"];
                } else {
                    [self.delegate unableToSubscribeOnInstrumentWithName:anInstrument
                                                             andExchange:[[self.subsctiptionSet objectForKey:anInstrument] objectForKey:@"exchange"]];
                    [self.subsctiptionSet removeObjectForKey:anInstrument];
                    NSLog(@"Unable to subscribe on instrument: %@", anInstrument);
                }
            }
        
            // if there is at least one instrument, we update it
            if ([self.subsctiptionSet count]) {
                while (myNumber == RUNNING_THREAD_NUMBER) {
                    p9mdi_dispatch_pending_events(connection);
                }
            }

            p9mdi_disconnect(connection);
        } 
        else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate errorOccured];
            });
        }
        isNetworkControllerActive = NO;
    });
}

- (void)stopEventMonitor
{
    RUNNING_THREAD_NUMBER++;
    cleanup_network_queue();
    shallNetworkControllerRun = NO;
}

-(void)addNameToUpdate:(NSString *)name
{
    [self.namesToUpdate addObject:name];
}

- (void)sendUpdateToDelegate
{
    if ([self.namesToUpdate count]) {
        NSSet *names = [NSSet setWithSet:self.namesToUpdate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shallNetworkControllerRun) {
                if ([self.delegate respondsToSelector:@selector(updateDataForNames:)]) {
                    [self.delegate updateDataForNames:names];
                }
            }
        });
        
        [self.namesToUpdate removeAllObjects];
    }
}


-(void) dealloc
{
    cleanup_network_queue();
    
    if (updateTimer) {
        [updateTimer invalidate];
    }
}

@end
