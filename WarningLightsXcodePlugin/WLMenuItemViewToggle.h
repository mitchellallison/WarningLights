//
//  WLMenuItemViewToggle.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 29/12/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface WLMenuItemViewToggle : NSButton

@property (strong) NSColor *fillColor;
@property (strong) NSColor *strokeColor;
@property BOOL highlighted;

- (instancetype)initWithFillColor:(NSColor *)color strokeColor:(NSColor *)color;

@end
