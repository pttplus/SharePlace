//
//  LocationPermissionChecker.m
//  SharePlace
//
//  Created by Wani on 2015/4/1.
//  Copyright (c) 2015年 watur. All rights reserved.
//

#import "LocationPermissionChecker.h"
#import <UIKit/UIKit.h>
#import "UIAlertView+Extension.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation LocationPermissionChecker

+ (void)check
{
    if([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Required"
                                                            message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            [alert sp_showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex != alert.cancelButtonIndex) {
                    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
                    if (canOpenSettings) {
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
            }];
        }
    }
}

@end
