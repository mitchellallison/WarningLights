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

- (instancetype)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode;

@property NSInteger state;

@end
