//
//  WLMenuItem.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 30/12/2013.
//
//

#import "WLMenuItem.h"
#import "WLMenuItemView.h"

@implementation WLMenuItem {
    SEL selector;
}

- (instancetype)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode
{
    if (self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode])
    {
        WLMenuItemView *itemView = [[WLMenuItemView alloc] init];
        [itemView.nameLabel setStringValue:aString];
        [itemView addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
        [self setView:itemView];
        selector = aSelector;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(WLMenuItemView *)menuItem change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        _state = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        NSLog(@"State: %lu", self.state);
        if ([self.target respondsToSelector:selector])
        {
            IMP imp = [self.target methodForSelector:selector];
            void (*func)(id, SEL, id) = (void *)imp;
            func(self.target, selector, self);
        }
    }
}

- (void)setState:(NSInteger)state
{
    WLMenuItemView *view = (WLMenuItemView *)self.view;
    [view updateWithState:state];
}

@end
