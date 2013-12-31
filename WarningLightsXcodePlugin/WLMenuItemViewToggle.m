//
//  WLMenuItemViewToggle.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 29/12/2013.
//
//

#import "WLMenuItemViewToggle.h"
#import "NSColor+WLColors.h"

static const NSRect innerToggle = {{5, 5}, {15, 15}};
static const CGFloat lineWidth = 1;

@implementation WLMenuItemViewToggle

/*! Initialises a toggle with a fill color and stroke color.
 *\param fill The fill NSColor for the toggle.
 *\param stroke The stroke NSColor for the outline of the toggle.
 */
- (instancetype)initWithFillColor:(NSColor *)fill strokeColor:(NSColor *)stroke
{
    if (self = [super init])
    {
        self.fillColor = fill;
        self.strokeColor = stroke;
        self.highlighted = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef graphicsContext = context.graphicsPort;
    
    CGContextSetLineWidth(graphicsContext, lineWidth);
    
    // If highlighted or in NSOnState
    if (self.highlighted || self.state) {
        
        // Highlight the button with a grey circular shadow.
        CGContextSetFillColorWithColor(graphicsContext, [NSColor opaqueGray].CGColor);
        CGContextSetStrokeColorWithColor(graphicsContext, [NSColor grayColor].CGColor);
        CGContextFillEllipseInRect(graphicsContext, CGRectMake(0, 0,
                                                               self.intrinsicContentSize.width,
                                                               self.intrinsicContentSize.height));
        CGContextStrokeEllipseInRect(graphicsContext, CGRectMake(lineWidth / 2,
                                                                 lineWidth / 2,
                                                                 self.intrinsicContentSize.width - lineWidth,
                                                                 self.intrinsicContentSize.height - lineWidth));
    }
    
    // Set the fill and stroke colors
    CGContextSetFillColorWithColor(graphicsContext, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(graphicsContext, self.strokeColor.CGColor);
    
    
    // Color the button with the specified fill and stroke
    CGContextFillEllipseInRect(graphicsContext, CGRectMake(innerToggle.origin.x, innerToggle.origin.y,
                                                           innerToggle.size.width,
                                                           innerToggle.size.height));
    CGContextStrokeEllipseInRect(graphicsContext, CGRectMake(innerToggle.origin.x + lineWidth / 2,
                                                             innerToggle.origin.y + lineWidth / 2,
                                                             innerToggle.size.width - lineWidth,
                                                             innerToggle.size.height - lineWidth));
    
}

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(25, 25);
}

- (void)setState:(NSInteger)value
{
    [self willChangeValueForKey:@"state"];
    [super setState:value];
    [self didChangeValueForKey:@"state"];
}

@end
