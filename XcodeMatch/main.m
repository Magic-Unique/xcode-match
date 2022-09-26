//
//  main.m
//  XcodeMatch
//
//  Created by Magic-Unique on 2022/09/26.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XcodeMatch.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CLMainExplain = @"This is command line project";
        CLMakeSubcommand(XcodeMatch, __init_);
        CLCommandMain();
    }
    return 0;
}
