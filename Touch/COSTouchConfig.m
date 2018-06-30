//
//  COSTouchConfig.m
//  COSTouchVisualizer
//
//  Created by Joseph Blau on 12/2/17.
//  Copyright © 2017 conopsys. All rights reserved.
//

#import "COSTouchConfig.h"

static const CGFloat COSTouchConfigContactAlpha = 0.5f;
static const CGFloat COSTouchConfigRippleAlpha = 0.2f;
static const NSTimeInterval COSTouchConfigContactFadeDuration = 0.3;
static const NSTimeInterval COSTouchConfigRippleFadeDuration = 0.2;

@implementation COSTouchConfig

-(instancetype)initWithTouchConfigType:(COSTouchConfigTpye)configType {
    self = [super init];
    if (self) {
        switch (configType) {
            case COSTouchConfigTpyeContact:
                [self _configureContact];
                break;
            case COSTouchConfigTpyeRipple:
                [self _configureRipple];
                break;
        }
    }
    return self;
}

#pragma mark - Private

-(void)_configureContact {
    self.strokeColor = [UIColor clearColor];
    self.fillColor = [[UIColor alloc] initWithRed:0.1315293405 green:0.6848516753 blue:0.9381706001 alpha:1];
    self.alpha = COSTouchConfigContactAlpha;
    self.fadeDuration = COSTouchConfigContactFadeDuration;
}

- (void)_configureRipple {
    self.strokeColor = [UIColor whiteColor];
    self.fillColor = [[UIColor alloc] initWithRed:0.1315293405 green:0.6848516753 blue:0.9381706001 alpha:1];
    self.alpha = COSTouchConfigRippleAlpha;
    self.fadeDuration = COSTouchConfigRippleFadeDuration;
}

@end
