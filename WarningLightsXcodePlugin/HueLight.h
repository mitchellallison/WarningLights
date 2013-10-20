
//
//  HueLight.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>
#import "HueLightDelegate.h"
#import "HueConstants.h"

@interface HueLight : NSObject

@property (strong) NSString *name;
@property (strong) NSString *uniqueID;
@property (strong) id <HueLightDelegate> delegate;

// Hue state. See http://developers.meethue.com for specifics.
@property (nonatomic) BOOL on;
@property (nonatomic) uint8_t brightness;
@property (nonatomic) uint16_t hue;
@property (nonatomic) uint8_t saturation;
@property (nonatomic) NSArray *cieXY;
@property (nonatomic) uint16_t miredColourTemperature;
@property (nonatomic) HueLightAlertType alert;
@property (nonatomic) HueLightEffectType effect;
@property (nonatomic) uint16_t transitionTime;

/*! Initialises an object to interact with a Philips Hue light bulb.
 *\param name The name dictated by the API.
 *\param uniqueID The id dictated by the API.
 *\param delegate A delegate to communicate reachability issues.
 *\returns A HueLight object that tracks light state.
 */
- (id)initWithName:(NSString *)name uniqueID:(NSString *)uniqueID delegate:(id)delegate;

/*! Synchronises a light bulb with the bridge, and calls a block upon completion.
 *\param block A completion handler to be called after sync.
 */
- (void)syncWithCompletionBlock:(void (^)())block;

/*! Push the state of the light bulb. Stack only currently has a depth of 1. */
- (void)pushState;

/*! Pop the state of the light bulb. Stack only currently has a depth of 1. */
- (void)popState;

/*! Pop the state of the light bulb over a specified transition_time. Stack only currently has a depth of 1.
 *\param transition_time The time over which to pop the state.
 */
- (void)popStateWithTransitionTime:(uint16_t)transitionTime;

/*! Commits a group of state changes simultaenously. It is recommended to use a transition_time within the block to dictate the length of time over which the change occurs.
 *\param changes A block of state changes.
 */
- (void)commitStateChanges:(void (^)())changes;

@end
