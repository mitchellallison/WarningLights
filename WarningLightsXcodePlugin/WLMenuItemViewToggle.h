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

/*! Initialises a toggle with a fill color and stroke color.
 *\param fill The fill NSColor for the toggle.
 *\param stroke The stroke NSColor for the outline of the toggle.
 */
- (instancetype)initWithFillColor:(NSColor *)fill strokeColor:(NSColor *)stroke;

@end
