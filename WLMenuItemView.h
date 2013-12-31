//
//  WLMenuItemView.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 26/12/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "WLMenuConstants.h"

@interface WLMenuItemView : NSView

/*! The label on the WLMenuItemView */
@property (strong) NSTextField *nameLabel;


/*! Updates the toggle with a given state.
 *\param state A WLMenuToggleType representing which options are switched on.
 */
- (void)updateWithState:(WLMenuItemToggleType)state;

@end
