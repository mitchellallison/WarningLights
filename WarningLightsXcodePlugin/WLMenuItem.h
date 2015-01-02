//
//  WLMenuItem.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 30/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "WLMenuConstants.h"

@interface WLMenuItem : NSMenuItem

/*! Initialises a WLMenuItem with a title, and an action.
 *\param aString The title of the menu item.
 *\param aSelector The callback for the menu item.
 *\param charCode A keyboard shortcut.
 */
- (instancetype)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode;

/*! Maintains the state of the WLMenuItem. See WLMenuItemToggleType for the different types of state. */
@property (nonatomic) WLMenuItemToggleType toggleType;

@end
