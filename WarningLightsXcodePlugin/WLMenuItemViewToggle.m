//
//  WLMenuItemViewToggle.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 29/12/2013.
//
//

#import "WLMenuItemViewToggle.h"

@implementation WLMenuItemViewToggle

- (instancetype)initWithFillColor:(NSColor *)fill strokeColor:(NSColor *)stroke
{
    if (self = [super init])
    {
        self.fillColor = fill;
        self.strokeColor = stroke;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef graphicsContext = context.graphicsPort;
    
    CGContextSetFillColorWithColor(graphicsContext, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(graphicsContext, self.strokeColor.CGColor);
    
    NSLog(@"%@", NSStringFromRect(dirtyRect));
    
    CGContextSetLineWidth(graphicsContext, 1);
        
    CGContextFillEllipseInRect(graphicsContext, CGRectMake(0, 0,
                                                           self.intrinsicContentSize.width,
                                                           self.intrinsicContentSize.height));
    CGContextStrokeEllipseInRect(graphicsContext, CGRectMake(0.5, 0.5,
                                                             self.intrinsicContentSize.width - 1,
                                                             self.intrinsicContentSize.height - 1));
}

- (NSSize)intrinsicContentSize
{
    return NSMakeSize(20, 20);
}

@end
