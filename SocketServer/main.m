//
//  main.m
//  SocketServer
//
//  Created by lasso on 16/8/3.
//  Copyright © 2016年 lasso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketServerManager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        SocketServerManager *socketServerMan = [SocketServerManager sharedManager];
        [socketServerMan startSocketWithPort:52000];
        
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
