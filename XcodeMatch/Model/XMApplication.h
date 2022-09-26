//
//  ASXApplication.h
//  AutoSelectXcode
//
//  Created by Magic-Unique on 2022/9/20.
//  Copyright © 2022 Magic-Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUVersion.h"

@interface XMApplication : NSObject

@property (nonatomic, strong, readonly) MUPath *path;

@property (nonatomic, strong, readonly) MUVersion *version;

@property (nonatomic, assign, readonly) BOOL isBeta;

+ (instancetype)applicationWithPath:(MUPath *)path;

@end
