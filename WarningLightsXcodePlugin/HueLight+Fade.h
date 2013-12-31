//
//  HueLight+Fade.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 31/12/2013.
//
//

#import "HueLight.h"

@interface HueLight (Fade)

- (void)fadeLightToHue:(uint16_t)hue sat:(uint8_t)sat bri:(uint8_t)bri overTransitionTime:(uint16_t)time;

@end
