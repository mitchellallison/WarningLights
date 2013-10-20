//
//  HueLightDelegate.h
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import <Foundation/Foundation.h>

@protocol HueLightDelegate <NSObject>

/*! Delegate method used to retrieve the base bridge URL in order to communicate with the API endpoint. */
- (NSURL *)bridgeBaseURLWithUsername;

/*! Delegate method used to communicate an issue with reaching the bridge. */
- (void)searchForBridge;

@end
