//
//  AppDelegate.m
//  SharePlace
//
//  Created by tureki on 3/31/15.
//  Copyright (c) 2015 watur. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "LocationPermissionChecker.h"
#import "Harpy.h"
#import "GCNetworkReachability.h"

@interface AppDelegate ()<FBSDKMessengerURLHandlerDelegate>
    @property (strong, nonatomic) FBSDKMessengerURLHandler *_messengerUrlHandler;
    @property (strong, nonatomic) GCNetworkReachability *reachability;

// shareMode holds state indicating which flow the user is in.
// Return the corresponding FBSDKMessengerContext based on that state.

@end

@implementation AppDelegate{
    id services_;
}

- (void)setHarpyForCheckingAppVersion
{
    // Set the App ID for your app
    [[Harpy sharedInstance] setAppID:@"981915503"];
    
    [[Harpy sharedInstance] setAppName:@"SharePlace"];
    
    // Set the UIViewController that will present an instance of UIAlertController
    [[Harpy sharedInstance] setPresentingViewController:self.window.rootViewController];
    
    // Perform check for new version of your app
    [[Harpy sharedInstance] checkVersion];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [GMSServices provideAPIKey:@"AIzaSyDkhoUj-aNxrzKRsxXWjDTT35qUJBGd_mE"];
    services_ = [GMSServices sharedServices];
    
    [self setHarpyForCheckingAppVersion];
    
    self._messengerUrlHandler = [[FBSDKMessengerURLHandler alloc] init];
    
    self._messengerUrlHandler.delegate = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    self.reachability = [GCNetworkReachability reachabilityWithHostName:@"www.google.com"];
    
    [self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connect Required"
                                                        message:@"Check your internet connection."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        // this block is called on the main thread
        switch (status) {
            case GCNetworkReachabilityStatusNotReachable:
                
                [alert show];
                
                break;
            case GCNetworkReachabilityStatusWWAN:
            case GCNetworkReachabilityStatusWiFi:
                // e.g. start syncing...
                break;
        }
    }];
    
    [FBSDKAppEvents activateApp];
    
    [LocationPermissionChecker check];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    // Check if the handler knows what to do with this url
    if ([self._messengerUrlHandler canOpenURL:url sourceApplication:sourceApplication]) {
        // Handle the url
        [self._messengerUrlHandler openURL:url sourceApplication:sourceApplication];
    }
    
    return YES;
}


@end
