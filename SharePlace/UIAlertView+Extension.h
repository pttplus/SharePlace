//
//  UIAlertView+Utils.h
//  PTTClient
//
//  Created by Wani on 2014/7/13.
//  Copyright (c) 2014年 Rainbow Tree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Extension)

- (void)sp_showWithCompletion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))completion;
- (void)sp_showWithCompletion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))completion andDismissCompletion:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))dismissCompletion;
@end
