//
//  ProfileItem.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum ProfileItemBuildType {
    kProfileItemBuildTypeDevelopment = 0,
    kProfileItemBuildTypeAdhoc,
    kProfileItemBuildTypeAppStore,
    kProfileItemBuildTypeEnterprise
} ProfileItemBuildType;

@class ProfileEntitlement;

@interface ProfileItem : NSObject

@property(nonatomic,copy,readonly)NSString *appIDName;
@property(nonatomic,copy,readonly)NSString *applicationIdentifierPrefix;
@property(nonatomic,strong,readonly)NSDate *creationDate;
@property(nonatomic,strong,readonly)ProfileEntitlement *entitlements;
@property(nonatomic,strong,readonly)NSDate *expirationDate;
@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,copy,readonly)NSString *teamIdentifier;
@property(nonatomic,copy,readonly)NSString *teamName;
@property(nonatomic,strong,readonly)NSNumber *timeToLive;
@property(nonatomic,copy,readonly)NSString *uuid;
@property(nonatomic,strong,readonly)NSArray *provisionedDevices;

//For bindings, someone probably could do this better if they knew how...
@property(nonatomic,copy,readonly)NSString *buildTypeString;
@property(nonatomic,copy,readonly)NSString *expirationDateString;
@property(nonatomic,copy,readonly)NSString *testFlightEnabledString;
@property(nonatomic,copy,readonly)NSString *statusIndicatorLight;

@property(nonatomic,assign)BOOL isOlderDuplicateProfile;
@property(nonatomic,copy)NSString *filePath;

@property(nonatomic,assign,readonly)ProfileItemBuildType buildType;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
-(instancetype)initWithFilePath:(NSString*)filePath;

-(BOOL)isEquivalentToProfile:(ProfileItem*)object;
@end
