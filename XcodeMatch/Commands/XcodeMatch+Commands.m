//
//  XcodeMatch+Commands.m
//  XcodeMatch
//
//  Created by Magic-Unique on 2022/09/26.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import "XcodeMatch+Commands.h"
#import "XMApplication.h"

@implementation XcodeMatch (Commands)

+ (void)__init_cmd {
    // define command `demo`, You can exec to do the block:
    // $ xcode-match demo
    CLCommand *cmd = [CLCommand mainCommand];
    cmd.explain = @"Match Xcode.";
    cmd.setQuery(@"version").setAbbr('v').optional().setExample(@"13.0/~> 13.0/lastest").setExplain(@"Special version");
    cmd.setFlag(@"show-path").setAbbr('P').setExplain(@"Print full path");
    cmd.setFlag(@"show-version").setAbbr('V').setExplain(@"Print version");
    cmd.setFlag(@"only").setAbbr('O').setExplain(@"Only print the lastest item");
    cmd.setFlag(@"beta").setAbbr('B').setExplain(@"Include beta version");
    cmd.setFlag(@"sort").setAbbr('S').setExplain(@"Sort large to small, default is small to large");
    [cmd handleProcess:^int(CLCommand * _Nonnull command, CLProcess * _Nonnull process) {
        // handle arguments with `process`
        BOOL SHOW_PATH = [process flag:@"show-path"];
        BOOL SHOW_VERSION = [process flag:@"show-version"];
        BOOL ONLY_LASTEST = [process flag:@"only-lastest"];
        BOOL SORT = [process flag:@"sort"];
        BOOL BETA = [process flag:@"beta"];
        
        MUPath *root = [MUPath pathWithString:@"/Applications"];
        NSMutableArray<XMApplication *> *list = [NSMutableArray array];
        [root enumerateContentsUsingBlock:^(MUPath *content, BOOL *stop) {
            if (content.isDirectory && [content.lastPathComponent hasPrefix:@"Xcode"] && [content isA:@"app"]) {
                [list addObject:[XMApplication applicationWithPath:content]];
            }
        }];
        
        if (list.count == 0) {
            CLError(@"本地没有安装 Xcode");
            return 1;
        }
        
        // Filter
        NSMutableArray<XMApplication *> *targets = list;
        if (!BETA) {
            [targets filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(XMApplication *evaluatedObject, id bindings) {
                return !evaluatedObject.isBeta;
            }]];
        }
        if (process.queries[@"version"]) {
            NSString *VERSION = process.queries[@"version"];
            if ([VERSION.lowercaseString isEqualToString:@"lastest"]) {
                targets = [self selectLastestInList:list];
            }
            else if ([VERSION hasPrefix:@"~> "]) {
                NSString *ver = [VERSION stringByReplacingOccurrencesOfString:@"~> " withString:@""];
                targets = [self selectRangeVersion:ver inList:list];
            }
            else {
                targets = [self selectVersion:VERSION inList:list];
            }
        }
        
        
        if (!targets.count) {
            CLError(@"没有符合条件的 Xcode");
            return 2;
        }
        
        // Sort
        XMApplication *lastest = nil;
        if (SORT) {
            [targets sortUsingComparator:^NSComparisonResult(XMApplication *obj1, XMApplication *obj2) {
                return [obj2.version compare:obj2.version];
            }];
            lastest = targets.firstObject;
        } else {
            [targets sortUsingComparator:^NSComparisonResult(XMApplication *obj1, XMApplication *obj2) {
                return [obj1.version compare:obj2.version];
            }];
            lastest = targets.lastObject;
        }
        
        // Print
        void (^showItem)(XMApplication *item) = ^(XMApplication *item) {
            if (SHOW_VERSION && SHOW_PATH) {
                CLPrintf(@"%@\t%@\n", item.version.stringValue, item.path.string);
            }
            else if (SHOW_VERSION) {
                CLPrintf(@"%@\n", item.version.stringValue);
            }
            else if (SHOW_PATH) {
                CLPrintf(@"%@\n", item.path.string);
            }
            else {
                CLPrintf(@"%@\n", item.path.lastPathComponent);
            }
        };
        
        if (ONLY_LASTEST) {
            showItem(lastest);
        } else {
            [targets enumerateObjectsUsingBlock:^(XMApplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                showItem(obj);
            }];
        }
        
        return 0; // return the command result.
    }];
}

+ (NSMutableArray<XMApplication *> *)selectLastestInList:(NSMutableArray<XMApplication *> *)list {
    [list sortUsingComparator:^NSComparisonResult(XMApplication *obj1, XMApplication *obj2) {
        return [obj1.version compare:obj2.version];
    }];
    return list;
}

+ (NSMutableArray<XMApplication *> *)selectRangeVersion:(NSString *)version inList:(NSMutableArray<XMApplication *> *)list {
    NSMutableArray *matches = [NSMutableArray array];
    
    MUVersion *minVer = [MUVersion versionWithString:version];
    MUVersion *maxVer = ({
        NSMutableArray *vs = [version componentsSeparatedByString:@"."].mutableCopy;
        if (vs.count < 1) {
            return nil;
        }
        vs[vs.count - 1] = @"999";
        NSString *ver = [vs componentsJoinedByString:@"."];
        [MUVersion versionWithString:ver];
    });
    
    [list enumerateObjectsUsingBlock:^(XMApplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.version isLessThan:minVer]) { return; }
        if ([obj.version isLargeThen:maxVer]) { return; }
        [matches addObject:obj];
    }];
    
    [matches sortUsingComparator:^NSComparisonResult(XMApplication *obj1, XMApplication *obj2) {
        return [obj1.version compare:obj2.version];
    }];
    return matches;
}

+ (NSMutableArray<XMApplication *> *)selectVersion:(NSString *)version inList:(NSMutableArray<XMApplication *> *)list {
    NSMutableArray *matches = [NSMutableArray array];
    
    MUVersion *ver = [MUVersion versionWithString:version];
    
    [list enumerateObjectsUsingBlock:^(XMApplication * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.version isEqualTo:ver]) {
            [matches addObject:obj];
        }
    }];
    
    [matches sortUsingComparator:^NSComparisonResult(XMApplication *obj1, XMApplication *obj2) {
        return [obj1.version compare:obj2.version];
    }];
    return matches;
}

@end
