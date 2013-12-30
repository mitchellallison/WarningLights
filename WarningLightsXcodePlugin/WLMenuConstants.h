//
//  WLMenuConstants.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 30/12/2013.
//
//

#ifndef WarningLightsXcodePlugin_WLMenuConstants_h
#define WarningLightsXcodePlugin_WLMenuConstants_h

typedef NS_OPTIONS(NSInteger, WLMenuItemToggleType)
{
    WLMenuItemToggleTypeNone    = 0,
    WLMenuItemToggleTypeError   = 1 << 0,
    WLMenuItemToggleTypeWarning = 1 << 1,
    WLMenuItemToggleTypeAnalyze = 1 << 2,
    WLMenuItemToggleTypeSuccess = 1 << 3,
};

#endif
