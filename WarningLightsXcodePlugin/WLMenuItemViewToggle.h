//
//  WLMenuItemViewToggle.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 29/12/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface WLMenuItemViewToggle : NSView

@property (strong) NSColor *fillColor;
@property (strong) NSColor *strokeColor;

- (instancetype)initWithFillColor:(NSColor *)color strokeColor:(NSColor *)color;

@end
