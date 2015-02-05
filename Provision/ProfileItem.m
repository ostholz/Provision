//
//  ProfileItem.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "ProfileItem.h"
#import "ProfileEntitlement.h"

static NSDateFormatter *dateFormatter;

@implementation ProfileItem

-(instancetype)init
{
    NSLog(@"You should be using initWithDictionary: or initWithFilePath: on this class.");
    return nil;
}

-(instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
        });
        
        [self updateValuesFromDictionary:dictionary];
    }
    
    return self;
}

-(instancetype)initWithFilePath:(NSString*)filePath
{
    if ([[filePath pathExtension] isEqualToString:@"mobileprovision"]) {
        //Create a new Profile Item
        
        NSError *fileError;
        NSString *profileContents = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&fileError];
        
        if (!fileError) {
            
            //Verify we can find the beginning of the plist
            NSRange plistStart = [profileContents rangeOfString:@"<?xml"];
            NSRange plistEnd = [profileContents rangeOfString:@"</plist>"];
            
            if (plistStart.location != NSNotFound && plistEnd.location != NSNotFound)
            {
                
                NSString *plistContent = [profileContents substringWithRange:NSMakeRange(plistStart.location, (plistEnd.location + plistEnd.length) - plistStart.location)];
                
                NSPropertyListFormat format;
                NSError *propertyListError;
                NSDictionary *import = [NSPropertyListSerialization propertyListWithData:[plistContent dataUsingEncoding:NSUTF8StringEncoding] options:0 format:&format error:&propertyListError];
                
                if ([import isKindOfClass:[NSDictionary class]])
                {
                    self = [self initWithDictionary:import];
                    self.filePath = filePath;
                    return self;
                }
            }
        }
    }
    return nil;
}

-(void)updateValuesFromDictionary:(NSDictionary*)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    _appIDName = dictionary[@"AppIDName"];
    _applicationIdentifierPrefix = [dictionary[@"ApplicationIdentifierPrefix"] firstObject];
    _creationDate = dictionary[@"CreationDate"];
    _entitlements = [[ProfileEntitlement alloc] initWithDictionary:dictionary[@"Entitlements"]];
    _expirationDate = dictionary[@"ExpirationDate"];
    _name = dictionary[@"Name"];
    _teamIdentifier = [dictionary[@"TeamIdentifier"] firstObject];
    _teamName = dictionary[@"TeamName"];
    _timeToLive = dictionary[@"TimeToLive"];
    _uuid = dictionary[@"UUID"];
    _provisionedDevices = dictionary[@"ProvisionedDevices"];
    
    if (self.appIDName.length == 0)
    {
        _appIDName = self.name;
    }
    
    if (_provisionedDevices.count == 0 && !self.entitlements.getTaskAllow.boolValue) {
        
        if ([dictionary[@"ProvisionsAllDevices"] boolValue]) {
            _buildType = kProfileItemBuildTypeEnterprise;
            _buildTypeString = @"Enterprise";
        }
        else
        {
            _buildType = kProfileItemBuildTypeAppStore;
            _buildTypeString = @"App Store";
        }
    }
    else
    {
        if (self.entitlements.getTaskAllow.boolValue && _provisionedDevices.count > 0) {
            _buildType = kProfileItemBuildTypeAdhoc;
            _buildTypeString = @"Ad hoc";
        }
        else
        {
            _buildType = kProfileItemBuildTypeDevelopment;
            _buildTypeString = @"Development";
        }
    }
    
    _testFlightEnabledString = self.entitlements.isTestFlightEnabled ? @"YES" : @"NO";
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    _expirationDateString = [dateFormatter stringFromDate:self.expirationDate];
    
    [self updateStatusIndicatorLight];
}

-(void)setIsOlderDuplicateProfile:(BOOL)isOlderDuplicateProfile
{
    _isOlderDuplicateProfile = isOlderDuplicateProfile;
    [self updateStatusIndicatorLight];
}

-(void)updateStatusIndicatorLight
{
    if ([[NSDate date] compare:self.expirationDate] == NSOrderedDescending) {
        _statusIndicatorLight = @"😡";
    }
    else
    {
        if (self.isOlderDuplicateProfile) {
            _statusIndicatorLight = @"😈";
        }
        else
        {
            _statusIndicatorLight = @"😀";
        }
    }
}

-(BOOL)isEquivalentToProfile:(ProfileItem*)object
{
    if ([self.applicationIdentifierPrefix isEqualToString:object.applicationIdentifierPrefix] &&
        [self.teamIdentifier isEqualToString:object.teamIdentifier] &&
        self.buildType == object.buildType &&
        [self.entitlements.applicationIdentifier isEqualToString:object.entitlements.applicationIdentifier]) {
        return YES;
    }
    
    return NO;
}
@end
