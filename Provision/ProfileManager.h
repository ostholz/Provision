//
//  ProfileManager.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProfileSource;

@interface ProfileManager : NSObject

@property(nonatomic,strong,readonly)ProfileSource *profileSource;

-(instancetype)initWithProfileSource:(ProfileSource*)source;

-(NSArray*)getProfileItems;

@end
