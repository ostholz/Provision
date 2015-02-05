//
//  ProfileSource.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "ProfileSource.h"

@implementation ProfileSource

-(instancetype)initWithDirectory:(NSString*)path name:(NSString*)name
{
    if (self = [super init]) {
        _name = name;
        _path = [path stringByExpandingTildeInPath];
    }
    
    return self;
}
@end
