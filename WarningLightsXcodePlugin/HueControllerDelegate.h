//
//  HueControllerDelegate.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>

@protocol HueControllerDelegate <NSObject>

/*! Delegate method signalling that no Philips Hue bridge could be found. */
- (void)bridgeNotFound;

/*! The user is required to press the link button on the Philips Hue Bridge.
    Once this has been done, the completion block may then be called to 
    authenticate with the bridge.
 *\param bridgeIP An NSString relating to the Bridge IP address that was found.
 *\param completion An authentication block to call once the button has been pressed.
 */
- (void)bridgeRequiresUserAuthentication:(NSString *)bridgeIP completion:(void (^)())completion;

/*! Delegate method signalling that the bridge is now authenticated. 
 *\param bridgeIP The authenticated bridgeIP.
 */
- (void)bridgeAuthenticated:(NSString *)bridgeIP;

@optional

/* Provides an NSArray of lights that have been discovered.
 *\param lights An array of HueLight objects.
 */
- (void)lightsFound:(NSArray *)lights;

@end
