//
//  SocketServerManager.h
//  SocketServer
//
//  Created by lasso on 16/8/3.
//  Copyright © 2016年 lasso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketServerManager : NSObject

+ (instancetype)sharedManager;
- (void)startSocket;

@end
