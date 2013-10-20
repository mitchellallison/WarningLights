//
//  HueStateChangeOperationDelegate.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>

@protocol HueStateChangeOperationDelegate <NSObject>

/*! Delegate method to signify the successful state update of a Hue lightbulb.
 *\param state A dictionary of state updates for the Hue lightbulb.
 */
- (void)hueStateDidChangeWithDictionary:(NSDictionary *)state;

/*! Delegate method used to communicate an issue with reaching the bridge. */
- (void)errorConnectingToBridge;

@end
