//
//  NSColor+WLColors.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 29/12/2013.
//
//

#import "NSColor+WLColors.h"

@implementation NSColor (WLColors)

+ (NSColor *)pastelRed
{
    return [NSColor colorWithSRGBRed:255/255.0f green:138/255.0f blue:138.0/255.0f alpha:1.0];
}

+ (NSColor *)outlineRed
{
    return [NSColor colorWithSRGBRed:215/255.0f green:110/255.0f blue:110/255.0f alpha:1.0];
}


+ (NSColor *)pastelOrange
{
    return [NSColor colorWithSRGBRed:255/255.0f green:200/255.0f blue:60/255.0f alpha:1.0];
}

+ (NSColor *)outlineOrange
{
    return [NSColor colorWithSRGBRed:255/255.0f green:155/255.0f blue:16/255.0f alpha:1.0];

}

+ (NSColor *)pastelBlue
{
    return [NSColor colorWithSRGBRed:150/255.0f green:210/255.0f blue:255/255.0f alpha:1.0];

}

+ (NSColor *)outlineBlue
{
    return [NSColor colorWithSRGBRed:110/255.0f green:162/255.0f blue:205/255.0f alpha:1.0];
}


+ (NSColor *)pastelGreen
{
    return [NSColor colorWithSRGBRed:190/255.0f green:240/255.0f blue:39/255.0f alpha:1.0];
}

+ (NSColor *)outlineGreen
{
    return [NSColor colorWithSRGBRed:162/255.0f green:205/255.0f blue:41/255.0f alpha:1.0];
}

+ (NSColor *)opaqueGray
{
    return [NSColor colorWithSRGBRed:217/255.0f green:217/255.0f blue:217/255.0f alpha:0.5];
}


@end
