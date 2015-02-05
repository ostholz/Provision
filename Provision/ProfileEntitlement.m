//
//  ProfileEntitlement.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "ProfileEntitlement.h"

@implementation ProfileEntitlement

-(instancetype)init
{
    NSLog(@"You should be using initWithDictionary: on this class.");
    return nil;
}

-(instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init]) {
        [self updateValuesFromDictionary:dictionary];
    }
    
    return self;
}

-(void)updateValuesFromDictionary:(NSDictionary*)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    _applicationIdentifier = dictionary[@"application-identifier"];
    _apsEnvironment = dictionary[@"aps-environment"];
    _teamIdentifier = dictionary[@"com.apple.developer.team-identifier"];
    _getTaskAllow = dictionary[@"get-task-allow"];
    _isTestFlightEnabled = [dictionary[@"beta-reports-active"] boolValue];
}
@end
