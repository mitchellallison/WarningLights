//
//  HueController.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>
#import "HueLight.h"
#import "HueControllerDelegate.h"

@interface HueController : NSObject <HueLightDelegate>

/*! A HueController object used to manage the state of Philips Hue light bulbs.
 *\param delegate A HueControllerDelegate object used to receive state 
                    updates and authentication requests.
 *\returns A HueController.
 */
- (instancetype)initWithDelegate:(id<HueControllerDelegate>)delegate;

/*! Searches for, and attempts to authenticate with, a bridge, delegating tasks
    back as necessary. */
- (void)searchForBridge;

/*! Returns a HueLight object with a given unique ID.
 *\param ID An NSString with the ID value of a light. IDs can be obtained from
            the delegate.
 *\returns A HueLight object relating to the unique ID.
 */
- (HueLight *)lightWithID:(NSString *)ID;

/*! Returns a HueLight object with a given name.
 *\param ID An NSString with the name value of a light.
 *\returns A HueLight object relating to the name.
 */
- (HueLight *)lightWithName:(NSString *)name;

@property (nonatomic, strong) NSURL *bridgeIP;

@end
