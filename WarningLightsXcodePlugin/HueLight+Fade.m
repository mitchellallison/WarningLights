//
//  HueLight+Fade.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 31/12/2013.
//
//

#import "HueLight+Fade.h"

@implementation HueLight (Fade)

- (void)fadeLightToHue:(uint16_t)hue sat:(uint8_t)sat bri:(uint8_t)bri overTransitionTime:(uint16_t)time
{
    // Perform changes all at once
    [self commitStateChanges:^{
        /* Sets a light on, to hue, sat and bri for time/10 seconds */
        [self setOn:YES];
        [self setHue:hue];
        [self setTransitionTime:time];
        [self setBrightness:bri];
        [self setSaturation:sat];
        [self setAlert:HueLightAlertTypeNone];
        [self setEffect:HueLightEffectTypeNone];
    }];
}

@end
