//
//  ProfileSource.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileSource : NSObject

@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,copy,readonly)NSString *path;

-(instancetype)initWithDirectory:(NSString*)path name:(NSString*)name;
@end
