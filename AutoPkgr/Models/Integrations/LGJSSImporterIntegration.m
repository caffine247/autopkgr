//
//  LGJSSImporterIntegration.m
//  AutoPkgr
//
//  Copyright 2015 Eldon Ahrold
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "LGIntegration+Protocols.h"
#import "LGJSSImporterIntegration.h"
#import "LGLogger.h"
#import "LGServerCredentials.h"

@interface LGJSSImporterIntegration () <LGIntegrationPackageInstaller, LGIntegrationSharedProcessor>
@end

@implementation LGJSSImporterIntegration
@synthesize installedVersion = _installedVersion;

#pragma mark - Class overrides
+ (NSString *)name
{
    return @"JSSImporter";
}

+ (NSString *)credits
{
    return @"Shea Craig, Mosen, Graham Pugh\nhttp://www.apache.org/licenses/LICENSE-2.0\nhttps://github.com/jssimporter/JSSImporter";
}

+ (NSString *)gitHubURL
{
    return @"https://api.github.com/repos/jssimporter/JSSImporter/releases";
}

+ (NSString *)defaultRepository
{
    return @"https://github.com/autopkg/jss-recipes.git";
}

+ (NSString *)binary
{
    return @"/Library/AutoPkg/autopkglib/JSSImporter.py";
}

+ (NSArray *)components
{
    return @[
        [self binary],
    ];
}

+ (NSArray *)packageIdentifiers
{
    return @[ @"com.github.jssimporter",
              @"com.github.sheagcraig.jssimporter",
              @"com.github.sheagcraig.jss-autopkg-addon" ];
}

+ (BOOL)isUninstallable
{
    return YES;
}

+ (NSString *)summaryResultKey
{
    return @"jss_importer_summary_result";
}

#pragma mark - Instance overrides.
- (NSString *)installedVersion
{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSString *jssAddonReceipt = @"/private/var/db/receipts/com.github.sheagcraig.jss-autopkg-addon.plist";

    NSString *jssImporterReceipt = @"/private/var/db/receipts/com.github.sheagcraig.jssimporter.plist";
    
    NSString *newJssImporterReceipt = @"/private/var/db/receipts/com.github.jssimporter.plist";

    if ([[self class] isInstalled]) {
        NSDictionary *receiptDict;
        if ([fm fileExistsAtPath:newJssImporterReceipt]) {
            receiptDict = [NSDictionary dictionaryWithContentsOfFile:newJssImporterReceipt];
        }
        else if ([fm fileExistsAtPath:jssImporterReceipt]) {
            receiptDict = [NSDictionary dictionaryWithContentsOfFile:jssImporterReceipt];
        }
        else if ([fm fileExistsAtPath:jssAddonReceipt]) {
            receiptDict = [NSDictionary dictionaryWithContentsOfFile:jssAddonReceipt];
        }
        _installedVersion = receiptDict[@"PackageVersion"];
    }

    return _installedVersion;
}

- (void)customInstallActions:(void (^)(NSError *))reply
{
    LGJSSImporterDefaults *defaults = [[LGJSSImporterDefaults alloc] init];
    NSNumber *verifySSL = [defaults autoPkgDomainObject:@"JSS_VERIFY_SSL"];
    if (!verifySSL) {
        defaults.JSSVerifySSL = YES;
    }
    reply(nil);
}

- (void)customUninstallActions:(void (^)(NSError *))reply
{
    // Clear out the defaults.
    LGJSSImporterDefaults *defaults = [[LGJSSImporterDefaults alloc] init];
    defaults.JSSAPIPassword = nil;
    defaults.JSSAPIUsername = nil;
    defaults.JSSRepos = nil;
    defaults.JSSURL = nil;

    reply(nil);
}

@end

#pragma mark - LGDefaults category implementation for JSSImporter Interface

@implementation LGJSSImporterDefaults

- (NSString *)JSSURL
{
    return [self autoPkgDomainObject:@"JSS_URL"];
}

- (void)setJSSURL:(NSString *)JSSURL
{
    [self setAutoPkgDomainObject:JSSURL forKey:@"JSS_URL"];
}

#pragma mark -
- (NSString *)JSSAPIUsername
{
    return [self autoPkgDomainObject:@"API_USERNAME"];
}

- (void)setJSSAPIUsername:(NSString *)JSSAPIUsername
{
    [self setAutoPkgDomainObject:JSSAPIUsername forKey:@"API_USERNAME"];
}

#pragma mark -
- (NSString *)JSSAPIPassword
{
    return [self autoPkgDomainObject:@"API_PASSWORD"];
}

- (void)setJSSAPIPassword:(NSString *)JSSAPIPassword
{
    [self setAutoPkgDomainObject:JSSAPIPassword forKey:@"API_PASSWORD"];
}

#pragma mark -
- (NSArray *)JSSRepos
{
    return [self autoPkgDomainObject:@"JSS_REPOS"];
}

- (void)setJSSRepos:(NSArray *)JSSRepos
{
    [self setAutoPkgDomainObject:JSSRepos forKey:@"JSS_REPOS"];
}

#pragma mark -
- (BOOL)JSSVerifySSL
{
    NSNumber *verifySSL = [self autoPkgDomainObject:@"JSS_VERIFY_SSL"];
    if (verifySSL == nil) {
        return YES;
    }

    return [verifySSL boolValue];
}

- (void)setJSSVerifySSL:(BOOL)JSSVerifySSL
{
    DevLog(@"Setting JSS_SSL_VERIFY to %@", JSSVerifySSL ? @"YES" : @"NO");
    [self setAutoPkgDomainObject:@(JSSVerifySSL) forKey:@"JSS_VERIFY_SSL"];
}

@end
