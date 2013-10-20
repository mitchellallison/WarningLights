//
//  HueConstants.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#ifndef WarningLightsXcodePlugin_HueConstants_h
#define WarningLightsXcodePlugin_HueConstants_h

static NSString *const bridgeRequestURL = @"http://www.meethue.com/api/nupnp";
static NSString *const internalIPAddressKey = @"internalipaddress";
static NSString *const errorKey = @"error";
static NSString *const descriptionKey = @"description";
static NSString *const successKey = @"success";
static NSString *const usernameKey = @"username";
static NSString *const nameKey = @"name";
static NSString *const whitelistKey = @"whitelist";
static NSString *const bridgeIPKey = @"bridgeIP";

static NSString *const onKey = @"on";
static NSString *const briKey = @"bri";
static NSString *const hueKey = @"hue";
static NSString *const satKey = @"sat";
static NSString *const cieKey = @"xy";
static NSString *const miredColourTemperatureKey = @"ct";
static NSString *const alertKey = @"alert";
static NSString *const effectKey = @"effect";
static NSString *const transitionTimeKey = @"transitiontime";

static NSString *const stateKey = @"state";

static NSString *selectedLightsKey = @"selectedLights";
static NSString *defaultSettingsKey = @"defaultSettings";

static NSString *const trueKey = @"true";
static NSString *const falseKey = @"false";

static const float kTransitionTimeFactor = 0.1;

typedef NS_ENUM(NSInteger, HueLightAlertType)
{
    HueLightAlertTypeNone,
    HueLightAlertTypeSelect,
    HueLightAlertTypeLSelect
};

typedef NS_ENUM(NSInteger, HueLightEffectType)
{
    HueLightEffectTypeNone,
    HueLightEffectTypeColorloop
};

#endif
