//
//  WarningLightsXcodePlugin.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>

#import "HueControllerDelegate.h"

static NSString *selectedLightsKey = @"selectedLights";
static NSString *lightOptionsKey = @"lightOptions";
static NSString *warningLightsSettingsKey = @"warningLightsSettings";

@interface WarningLightsXcodePlugin : NSObject <HueControllerDelegate>

@end
