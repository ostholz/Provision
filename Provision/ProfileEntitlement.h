//
//  ProfileEntitlement.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileEntitlement : NSObject

@property(nonatomic,copy,readonly)NSString *applicationIdentifier;
@property(nonatomic,copy,readonly)NSString *apsEnvironment;
@property(nonatomic,copy,readonly)NSString *teamIdentifier;
@property(nonatomic,strong,readonly)NSNumber *getTaskAllow;
@property(nonatomic,assign,readonly)BOOL isTestFlightEnabled;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@end
