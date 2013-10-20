//
//  HueLight.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import "HueLight.h"
#import "HueStateChangeOperation.h"
#import "HueStateChangeOperationDelegate.h"

@interface HueLight () <NSURLConnectionDataDelegate, HueStateChangeOperationDelegate>

@property (strong) NSDictionary *state;
@property (strong) NSOperationQueue *stateChangeQueue;
@property BOOL changeStateImmediately;
@property (nonatomic, strong) NSMutableDictionary *queuedStateDictionary;

@end

@implementation HueLight
@synthesize on = _on;
@synthesize brightness = _brightness;
@synthesize hue = _hue;
@synthesize saturation = _saturation;
@synthesize cieXY = _cieXY;
@synthesize miredColourTemperature = _miredColourTemperature;
@synthesize alert = _alert;
@synthesize effect = _effect;
@synthesize transitionTime = _transitionTime;

/*! Initialises an object to interact with a Philips Hue light bulb.
 *\param name The name dictated by the API.
 *\param uniqueID The id dictated by the API.
 *\param delegate A delegate to communicate reachability issues.
 *\returns A HueLight object that tracks light state.
 */
- (id)initWithName:(NSString *)name uniqueID:(NSString *)uniqueID delegate:(id)delegate
{
    if (self = [super init])
    {
        self.name = name;
        self.uniqueID = uniqueID;
        self.delegate = delegate;
        self.stateChangeQueue = [[NSOperationQueue alloc] init];
        self.stateChangeQueue.maxConcurrentOperationCount = 1;
        self.changeStateImmediately = YES;
    }
    return self;
}

/*! Synchronises a light bulb with the bridge, and calls a block upon completion.
 *\param block A completion handler to be called after sync.
 */
- (void)syncWithCompletionBlock:(void (^)())block
{
    NSURLRequest *lightRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"lights/%@", self.uniqueID] relativeToURL:[self.delegate bridgeBaseURLWithUsername]]];
    [NSURLConnection sendAsynchronousRequest:lightRequest queue:self.stateChangeQueue completionHandler:^(NSURLResponse *response, NSData *lightData, NSError *error) {
        if (lightData)
        {
            NSDictionary *lightDict = [NSJSONSerialization JSONObjectWithData:lightData options:0 error:nil];
            NSDictionary *stateDict = lightDict[stateKey];
            if (stateDict)
            {
                for (NSString *key in stateDict)
                {
                    NSString *kvKey = [self keyValueMapping][key];
                    if (kvKey)
                    {
                        [self setValue:stateDict[key] forKey:[@"_" stringByAppendingString:kvKey]];
                    }
                }
            }
        }
        else
            [self errorConnectingToBridge];
        
        block();
    }];
}

/*! Push the state of the light bulb. Stack only currently has a depth of 1. */
- (void)pushState
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"lights/%@", self.uniqueID] relativeToURL:[self.delegate bridgeBaseURLWithUsername]]];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *attributes = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (attributes)
    {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:attributes options:0 error:&error];
        self.state = [dictionary valueForKey:stateKey];
    }
}

/*! Pop the state of the light bulb. Stack only currently has a depth of 1. */
- (void)popState
{
    if (self.state)
    {
        [self changeStateWithDictionary:self.state];
        self.state = nil;
    }
}

/*! Pop the state of the light bulb over a specified transition_time. Stack only currently has a depth of 1.
 *\param transition_time The time over which to pop the state.
 */
- (void)popStateWithTransitionTime:(uint16_t)transitionTime
{
    if (self.state)
    {
        NSMutableDictionary *state = [self.state mutableCopy];
        [state setObject:@(transitionTime) forKey:transitionTimeKey];
        [self changeStateWithDictionary:state];
    }
}

/*! Commits a group of state changes simultaenously. It is recommended to use a transition_time within the block to dictate the length of time over which the change occurs.
 *\param changes A block of state changes.
 */
- (void)commitStateChanges:(void (^)())changes
{
    self.changeStateImmediately = NO;
    changes();
    self.changeStateImmediately = YES;
    [self changeStateWithDictionary:self.queuedStateDictionary];
    self.queuedStateDictionary = nil;
}

#pragma mark Asynchronous state change methods

- (void)changeStateWithDictionary:(NSDictionary *)dictionary
{
    if (self.changeStateImmediately)
    {
        HueStateChangeOperation *stateChangeOperation = [[HueStateChangeOperation alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"lights/%@/state", self.uniqueID] relativeToURL:[self.delegate bridgeBaseURLWithUsername]] state:dictionary delegate:self];
        [self.stateChangeQueue addOperation:stateChangeOperation];
    }
    else
    {
        [self.queuedStateDictionary addEntriesFromDictionary:dictionary];
    }
}

- (NSMutableDictionary *)queuedStateDictionary
{
    if (!_queuedStateDictionary)
    {
        _queuedStateDictionary = [NSMutableDictionary dictionaryWithDictionary:@{}];
    }
    return _queuedStateDictionary;
}

- (NSDictionary *)keyValueMapping
{
    return @{transitionTimeKey:@"transitionTime",
             briKey:@"brightness",
             satKey:@"saturation",
             miredColourTemperatureKey:@"miredColourTemperature",
             onKey:@"on",
             alertKey:@"alert",
             effectKey:@"effect",
             hueKey:@"hue",
             cieKey:@"cieXY"
             };
}

#pragma mark Hue state properties

- (void)setOn:(BOOL)on
{
    NSDictionary *stateChange = @{onKey: @(on)};
    [self changeStateWithDictionary:stateChange];
}

- (BOOL)on
{
    return _on;
}

- (void)setBrightness:(uint8_t)brightness
{
    NSDictionary *stateChange = @{briKey:[NSNumber numberWithUnsignedInteger:brightness]};
    [self changeStateWithDictionary:stateChange];
}

- (uint8_t)brightness
{
    return _brightness;
}

- (void)setHue:(uint16_t)hue
{
    NSDictionary *stateChange = @{hueKey:[NSNumber numberWithUnsignedInteger:hue]};
    [self changeStateWithDictionary:stateChange];
}

- (uint16_t)hue
{
    return _hue;
}

- (void)setSaturation:(uint8_t)saturation
{
    NSDictionary *stateChange = @{satKey:[NSNumber numberWithUnsignedInteger:saturation]};
    [self changeStateWithDictionary:stateChange];
}

- (uint8_t)saturation
{
    return _saturation;
}

- (void)setCieX:(NSArray *)cieXY
{
    _cieXY = cieXY;
}

- (void)setMiredColourTemperature:(uint16_t)miredColourTemperature
{
    NSDictionary *stateChange = @{miredColourTemperatureKey:[NSNumber numberWithUnsignedInteger:miredColourTemperature]};
    [self changeStateWithDictionary:stateChange];
}

- (uint16_t)miredColourTemperature
{
    return _miredColourTemperature;
}

- (void)setAlert:(HueLightAlertType)alert
{
    NSString *alertString = (alert == HueLightAlertTypeSelect) ? @"select" : (alert == HueLightAlertTypeLSelect) ? @"lselect" : @"none";
    NSDictionary *stateChange = @{alertKey: alertString};
    [self changeStateWithDictionary:stateChange];
}

- (HueLightAlertType)alert
{
    return _alert;
}

- (void)setEffect:(HueLightEffectType)effect
{
    NSString *effectString = (effect == HueLightEffectTypeColorloop) ? @"colorloop" : @"none";
    NSDictionary *stateChange = @{effectKey: effectString};
    [self changeStateWithDictionary:stateChange];
}

- (HueLightEffectType)effect
{
    return _effect;
}

- (void)setTransitionTime:(uint16_t)transitionTime
{
    NSDictionary *stateChange = @{transitionTimeKey:[NSNumber numberWithUnsignedInteger:transitionTime]};
    [self changeStateWithDictionary:stateChange];
}

- (uint16_t)transitionTime
{
    return _transitionTime;
}

- (NSString *)description
{
    return self.name;
}

#pragma mark HueStateChangeOperationDelegate

- (void)hueStateDidChangeWithDictionary:(NSDictionary *)state
{
    for (NSDictionary *result in state)
    {
        NSDictionary *successDict = result[successKey];
        if (successDict)
        {
            NSString *successValue = [[successDict allKeys] lastObject];
            if (successValue)
            {
                NSString *key = [[successValue pathComponents] lastObject];
                NSString *value = successDict[successValue];
                if ([self keyValueMapping][key])
                    key = [self keyValueMapping][key];
                key = [@"_" stringByAppendingString:key];
                [self setValue:value forKey:key];
            }
        }
    }
}

- (void)errorConnectingToBridge
{
    NSLog(@"Error connecting to bridge");
    [self.delegate searchForBridge];
}

@end
