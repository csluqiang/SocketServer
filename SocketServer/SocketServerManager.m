//
//  SocketServerManager.m
//  SocketServer
//
//  Created by lasso on 16/8/3.
//  Copyright © 2016年 lasso. All rights reserved.
//

#import "SocketServerManager.h"
#import "GCDAsyncSocket.h"

@interface SocketServerManager () <GCDAsyncSocketDelegate, NSNetServiceDelegate>
{
    NSNetService *netService;
    GCDAsyncSocket *asyncSocket;
    NSMutableArray *connectedSockets;
}

@end

@implementation SocketServerManager

+ (instancetype)sharedManager
{
    static dispatch_once_t token;
    __block SocketServerManager *sharedInstance = nil;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)startSocket
{
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // Create an array to hold accepted incoming connections.
    
    connectedSockets = [[NSMutableArray alloc] init];
    
    // Now we tell the socket to accept incoming connections.
    // We don't care what port it listens on, so we pass zero for the port number.
    // This allows the operating system to automatically assign us an available port.
    
    NSError *err = nil;
    if ([asyncSocket acceptOnPort:52000 error:&err])
    {
        // So what port did the OS give us?
        
        UInt16 port = [asyncSocket localPort];
        
        // Create and publish the bonjour service.
        // Obviously you will be using your own custom service type.
        
        netService = [[NSNetService alloc] initWithDomain:@"local."
                                                     type:@"_YourServiceName._tcp."
                                                     name:@""
                                                     port:port];
        
        [netService setDelegate:self];
        [netService publish];
        
        // You can optionally add TXT record stuff
        
        NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [txtDict setObject:@"moo" forKey:@"cow"];
        [txtDict setObject:@"quack" forKey:@"duck"];
        
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
        [netService setTXTRecordData:txtData];
    }
    else
    {
        NSLog(@"Error in acceptOnPort:error: -> %@", err);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    // The newSocket automatically inherits its delegate & delegateQueue from its parent.
    
    [connectedSockets addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [connectedSockets removeObject:sock];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [sock readDataWithTimeout:-1 tag:tag];
    
    NSString *longConnect = @"i recevice you.";
    
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [sock writeData:dataStream withTimeout:3 tag:tag];
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
    NSLog(@"LASSO Service Published: domain(%@) type(%@) name(%@) port(%i)",
          [ns domain], [ns type], [ns name], (int)[ns port]);
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
    // Override me to do something here...
    //
    // Note: This method in invoked on our bonjour thread.
    
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
          [ns domain], [ns type], [ns name], errorDict);
}

@end
