//
//  ProfileManager.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "ProfileManager.h"
#import "ProfileItem.h"
#import "ProfileSource.h"

@implementation ProfileManager

-(instancetype)initWithProfileSource:(ProfileSource*)source
{
    if (self = [super init]) {
        
        _profileSource = source;
    }
    
    return self;
}

-(NSArray*)getProfileItems
{
    NSMutableArray*profileItems = [NSMutableArray array];
    
    NSError *error;
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.profileSource.path error:&error];
    
    if (error) {
        return nil;
    }
    
    for (NSString *currentFolder in folderContents) {
        ProfileItem *item = [[ProfileItem alloc] initWithFilePath:[self.profileSource.path stringByAppendingPathComponent:currentFolder]];
        
        if (item) {
            [profileItems addObject:item];
        }
    }
    
    //Scan profiles and see if there are older ones. If there are, set the BOOL.
    for (ProfileItem *item in profileItems) {
        
        for (ProfileItem *testItem in profileItems) {
            
            if ([item isEquivalentToProfile:testItem] && [item.expirationDate compare:testItem.expirationDate] == NSOrderedDescending) {
                testItem.isOlderDuplicateProfile = YES;
            }
        }
    }
    
    return [profileItems sortedArrayUsingComparator:^NSComparisonResult(ProfileItem * obj1, ProfileItem * obj2) {
        return [obj1.name compare:obj2.name];
    }];
}

@end
