//
//  ASXApplication.m
//  AutoSelectXcode
//
//  Created by Magic-Unique on 2022/9/20.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import "XMApplication.h"

@implementation XMApplication

+ (instancetype)applicationWithPath:(MUPath *)path {
    MUPath *infoPath = [path subpathWithComponent:@"Contents/Info.plist"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath.string];
    
    XMApplication *app = [[self alloc] init];
    app->_path = path;
    app->_version = ({
        NSString *version = info[@"CFBundleShortVersionString"];
        [MUVersion versionWithString:version];
    });
    app->_isBeta = ({
        NSString *iconFile = info[@"CFBundleIconFile"];
        NSString *iconName = info[@"CFBundleIconName"];
        [iconFile containsString:@"Beta"] || [iconName containsString:@"Beta"];
    });
    return app;
}

@end
