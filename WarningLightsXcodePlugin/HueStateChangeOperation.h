//
//  HueStateChangeOperation.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>
#import "HueStateChangeOperationDelegate.h"

@interface HueStateChangeOperation : NSOperation

/*! Initialises a HueStateChangeOperation, which handles the asynchronous update of a Hue light bulb.
 *\param url The API endpoint to send the updates to.
 *\param state The state dictionary to update the light with. If the state dictates a transition_time, the operation will block the operation queue until the transition has occured.
 *\param delegate The delegate to send successful/failed state change information.
 *\returns A HueStateChangeOperation object to handle the asynchronous update of a Philips Hue light bulb.
 */
- (instancetype)initWithURL:(NSURL *)url state:(NSDictionary *)state delegate:(id<HueStateChangeOperationDelegate>)delegate;

@property (strong) id<HueStateChangeOperationDelegate> delegate;

@end
