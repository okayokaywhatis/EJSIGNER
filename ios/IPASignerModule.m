//
//  IPASignerModule.m
//  SignerApp
//
//  Implementation of advanced iOS app signing
//

#import "IPASignerModule.h"
#import <React/RCTLog.h>
#import <dlfcn.h>
#import <sys/stat.h>
#import <CommonCrypto/CommonDigest.h>

// Private framework imports (these won't be available in standard builds)
// In production, these would be loaded dynamically
@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (BOOL)installApplication:(NSURL *)url withOptions:(NSDictionary *)options;
- (BOOL)uninstallApplication:(NSString *)identifier withOptions:(NSDictionary *)options;
@end

@implementation IPASignerModule

RCT_EXPORT_MODULE();

// Sign an app bundle with the provided certificate
RCT_EXPORT_METHOD(signApp:(NSString *)appPath
                  certificatePath:(NSString *)certPath
                  password:(NSString *)password
                  bundleIdentifier:(NSString *)bundleId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        RCTLogInfo(@"Starting app signing process...");
        RCTLogInfo(@"App path: %@", appPath);
        RCTLogInfo(@"Certificate: %@", certPath);
        RCTLogInfo(@"Bundle ID: %@", bundleId);
        
        // Step 1: Load certificate data
        NSData *certData = [NSData dataWithContentsOfFile:certPath];
        if (!certData) {
            reject(@"cert_error", @"Failed to load certificate", nil);
            return;
        }
        
        // Step 2: Create entitlements
        NSDictionary *entitlements = @{
            @"application-identifier": bundleId,
            @"get-task-allow": @YES,
            @"keychain-access-groups": @[bundleId]
        };
        
        NSString *entitlementsPath = [NSString stringWithFormat:@"%@/entitlements.plist", NSTemporaryDirectory()];
        [entitlements writeToFile:entitlementsPath atomically:YES];
        
        // Step 3: Sign all frameworks and dylibs first
        [self signFrameworksInPath:appPath withCert:certPath];
        
        // Step 4: Sign the main app bundle
        NSString *codesignPath = @"/usr/bin/codesign";
        NSArray *arguments = @[
            @"-f",                          // Force
            @"-s", @"-",                    // Ad-hoc signature
            @"--entitlements", entitlementsPath,
            @"--generate-entitlement-der",
            appPath
        ];
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:codesignPath];
        [task setArguments:arguments];
        
        NSPipe *outputPipe = [NSPipe pipe];
        NSPipe *errorPipe = [NSPipe pipe];
        [task setStandardOutput:outputPipe];
        [task setStandardError:errorPipe];
        
        [task launch];
        [task waitUntilExit];
        
        int status = [task terminationStatus];
        
        if (status == 0) {
            RCTLogInfo(@"App signed successfully!");
            resolve(@"App signed successfully");
        } else {
            NSData *errorData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
            NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            RCTLogError(@"Codesign error: %@", errorString);
            reject(@"sign_error", errorString, nil);
        }
        
    } @catch (NSException *exception) {
        reject(@"exception", exception.reason, nil);
    }
}

// Helper method to sign frameworks and dylibs
- (void)signFrameworksInPath:(NSString *)appPath withCert:(NSString *)certPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:appPath];
    
    for (NSString *file in enumerator) {
        if ([file hasSuffix:@".framework"] || [file hasSuffix:@".dylib"] || [file hasSuffix:@".appex"]) {
            NSString *fullPath = [appPath stringByAppendingPathComponent:file];
            RCTLogInfo(@"Signing: %@", file);
            
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/usr/bin/codesign"];
            [task setArguments:@[@"-f", @"-s", @"-", fullPath]];
            [task launch];
            [task waitUntilExit];
        }
    }
}

// Install a signed IPA using private APIs
RCT_EXPORT_METHOD(installApp:(NSString *)ipaPath
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        RCTLogInfo(@"Attempting to install: %@", ipaPath);
        
        // Try to use LSApplicationWorkspace (private API)
        Class LSApplicationWorkspace_class = NSClassFromString(@"LSApplicationWorkspace");
        if (!LSApplicationWorkspace_class) {
            reject(@"api_error", @"LSApplicationWorkspace not available", nil);
            return;
        }
        
        id workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
        if (!workspace) {
            reject(@"workspace_error", @"Failed to get workspace", nil);
            return;
        }
        
        NSURL *ipaURL = [NSURL fileURLWithPath:ipaPath];
        NSDictionary *options = @{
            @"CFBundleIdentifier": @"com.signer.app"
        };
        
        SEL installSelector = NSSelectorFromString(@"installApplication:withOptions:");
        NSMethodSignature *signature = [workspace methodSignatureForSelector:installSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:installSelector];
        [invocation setTarget:workspace];
        [invocation setArgument:&ipaURL atIndex:2];
        [invocation setArgument:&options atIndex:3];
        [invocation invoke];
        
        BOOL result;
        [invocation getReturnValue:&result];
        
        if (result) {
            RCTLogInfo(@"Installation initiated successfully");
            resolve(@"Installation successful");
        } else {
            reject(@"install_error", @"Installation failed", nil);
        }
        
    } @catch (NSException *exception) {
        reject(@"exception", exception.reason, nil);
    }
}

// Get device UDID
RCT_EXPORT_METHOD(getDeviceUDID:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    // This would use IOKit or other private APIs to get UDID
    // For security, modern iOS restricts this
    resolve(@"UDID access restricted on modern iOS");
}

// Generate ad-hoc certificate
RCT_EXPORT_METHOD(generateAdHocCert:(NSString *)bundleId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        // This is a simplified version
        // Real implementation would generate proper certificates
        RCTLogInfo(@"Generating ad-hoc certificate for: %@", bundleId);
        
        NSString *certPath = [NSString stringWithFormat:@"%@/adhoc.p12", NSTemporaryDirectory()];
        
        // In a real implementation, this would:
        // 1. Generate a private/public key pair
        // 2. Create a certificate request
        // 3. Sign it locally for ad-hoc distribution
        
        resolve(certPath);
        
    } @catch (NSException *exception) {
        reject(@"generation_error", exception.reason, nil);
    }
}

// Verify app signature
RCT_EXPORT_METHOD(verifySignature:(NSString *)appPath
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/codesign"];
        [task setArguments:@[@"-v", @"-v", appPath]];
        
        NSPipe *outputPipe = [NSPipe pipe];
        [task setStandardOutput:outputPipe];
        [task setStandardError:outputPipe];
        
        [task launch];
        [task waitUntilExit];
        
        NSData *data = [[outputPipe fileHandleForReading] readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        int status = [task terminationStatus];
        
        if (status == 0) {
            resolve(@{@"valid": @YES, @"output": output});
        } else {
            resolve(@{@"valid": @NO, @"output": output});
        }
        
    } @catch (NSException *exception) {
        reject(@"verify_error", exception.reason, nil);
    }
}

@end
