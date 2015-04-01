//
//  UIAlertView+Utils.h
//  PTTClient
//
//  Created by Wani on 2014/7/13.
//  Copyright (c) 2014年 Rainbow Tree. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+Extension.h"

@interface NSCBAlertWrapper : NSObject <UIAlertViewDelegate>

@property(copy) void(^completionBlock)(UIAlertView *alertView, NSInteger buttonIndex);
@property(copy) void(^dismissBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@end

@implementation NSCBAlertWrapper

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.dismissBlock) {
        self.dismissBlock(alertView, buttonIndex);
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.completionBlock)
        self.completionBlock(alertView, buttonIndex);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView {
    // Just simulate a cancel button click
    if (self.completionBlock)
        self.completionBlock(alertView, alertView.cancelButtonIndex);
}

@end


static const char kNSCBAlertWrapper;

@implementation UIAlertView (Extension)

#pragma mark - Class Public

- (void)sp_showWithCompletion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))completion {
    NSCBAlertWrapper *alertWrapper = [[NSCBAlertWrapper alloc] init];
    alertWrapper.completionBlock = completion;
    self.delegate = alertWrapper;

    // Set the wrapper as an associated object
    objc_setAssociatedObject(self, &kNSCBAlertWrapper, alertWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // Show the alert as normal
    [self show];
}

- (void)sp_showWithCompletion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))completion andDismissCompletion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))dismissCompletion {
    NSCBAlertWrapper *alertWrapper = [[NSCBAlertWrapper alloc] init];
    alertWrapper.completionBlock = completion;
    alertWrapper.dismissBlock = dismissCompletion;
    self.delegate = alertWrapper;
    
    // Set the wrapper as an associated object
    objc_setAssociatedObject(self, &kNSCBAlertWrapper, alertWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Show the alert as normal
    [self show];
}

@end
