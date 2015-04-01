//
//  ShareButton.m
//  SharePlace
//
//  Created by Wani on 2015/4/1.
//  Copyright (c) 2015年 watur. All rights reserved.
//

#import "FBSendButton.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>

@interface FBSendButton()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@end

@implementation FBSendButton

- (void)setTarget:(id)target action:(SEL)action
{
    self.target = target;
    self.action = action;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIButton *button = [FBSDKMessengerShareButton rectangularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue];
    button.layer.cornerRadius = 0;
    button.frame = self.bounds;
    [button addTarget:self.target action:_action forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    return self;
}

@end
