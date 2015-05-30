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

/*! Initialises a WLMenuItem with a title, and an action.
 *\param aString The title of the menu item.
 *\param aSelector The callback for the menu item.
 *\param charCode A keyboard shortcut.
 */
- (instancetype)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode
{
    if (self = [super initWithTitle:aString action:aSelector keyEquivalent:charCode])
    {
        // Create the view
        WLMenuItemView *itemView = [[WLMenuItemView alloc] init];
        [itemView.nameLabel setStringValue:aString];
        
        // Observer for changes in state with the view.
        [itemView addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
        [self setView:itemView];
        selector = aSelector;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(WLMenuItemView *)menuItem change:(NSDictionary *)change context:(void *)context
{
    // If state changes
    if ([keyPath isEqualToString:@"state"])
    {
        // Store state locally
        _toggleType = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        // Call the selector
        if ([self.target respondsToSelector:selector])
        {
            IMP imp = [self.target methodForSelector:selector];
            void (*func)(id, SEL, id) = (void *)imp;
            func(self.target, selector, self);
        }
    }
}

// Delegate state change to the toggle
- (void)setToggleType:(WLMenuItemToggleType)toggleType
{
    WLMenuItemView *view = (WLMenuItemView *)self.view;
    _toggleType = toggleType;
    [view updateWithState:toggleType];
}

- (void)dealloc {
    [self.view removeObserver:self forKeyPath:@"state"];
}

@end
