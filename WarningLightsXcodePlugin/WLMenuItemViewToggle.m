//
//  WLMenuItemViewToggle.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 29/12/2013.
//
//

#import "WLMenuItemViewToggle.h"
#import "NSColor+WLColors.h"

static NSRect innerToggle = {{5, 5}, {15, 15}};

@implementation WLMenuItemViewToggle

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
    
    CGContextSetLineWidth(graphicsContext, 1);
    
    if (self.highlighted || self.state) {
        CGContextSetFillColorWithColor(graphicsContext, [NSColor opaqueGray].CGColor);
        CGContextSetStrokeColorWithColor(graphicsContext, [NSColor grayColor].CGColor);
        CGContextFillEllipseInRect(graphicsContext, CGRectMake(0, 0,
                                                               self.intrinsicContentSize.width,
                                                               self.intrinsicContentSize.height));
        CGContextStrokeEllipseInRect(graphicsContext, CGRectMake(0.5,
                                                                 0.5,
                                                                 self.intrinsicContentSize.width - 1,
                                                                 self.intrinsicContentSize.height - 1));
    }
    
    CGContextSetFillColorWithColor(graphicsContext, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(graphicsContext, self.strokeColor.CGColor);
    
    
    CGContextFillEllipseInRect(graphicsContext, CGRectMake(innerToggle.origin.x, innerToggle.origin.y,
                                                           innerToggle.size.width,
                                                           innerToggle.size.height));
    CGContextStrokeEllipseInRect(graphicsContext, CGRectMake(innerToggle.origin.x + 0.5,
                                                             innerToggle.origin.y + 0.5,
                                                             innerToggle.size.width - 1,
                                                             innerToggle.size.height - 1));
    
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
