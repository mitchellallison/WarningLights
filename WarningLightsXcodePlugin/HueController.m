//
//  HueController.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import "HueConstants.h"
#import "HueController.h"
#import "HueLightDelegate.h"

@interface HueController ()

@property id <HueControllerDelegate> delegate;
@property (nonatomic, strong) NSURL *bridgeIP;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSMutableArray *lights;

@end

@implementation HueController
@synthesize username = _username;
@synthesize bridgeIP = _bridgeIP;

/*! A HueController object used to manage the state of Philips Hue light bulbs.
 *\param delegate A HueControllerDelegate object used to receive state
 updates and authentication requests.
 *\returns A HueController.
 */
- (id)initWithDelegate:(id<HueControllerDelegate>)delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
        [self searchForBridge];
    }
    return self;
}

#pragma mark @property accessors

- (NSString *)username
{
    // Get the username from NSUserDefaults if it exists
    NSDictionary *defaultSettings = [[NSUserDefaults standardUserDefaults] objectForKey:defaultSettingsKey];
    return defaultSettings[usernameKey];
}

- (void)setUsername:(NSString *)username
{
    // Save the username to NSUserDefaults
    _username = username;
    NSDictionary *defaultSettings = @{usernameKey: username, selectedLightsKey: [NSMutableArray array]};
    [[NSUserDefaults standardUserDefaults] setObject:defaultSettings forKey:defaultSettingsKey];
    
}

- (NSMutableArray *)lights
{
    if (!_lights)
    {
        _lights = [[NSMutableArray alloc] init];
    }
    return _lights;
}

- (NSURL *)bridgeIP
{
    // Makes a request to get the bridge IP from the network if one exists.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:bridgeRequestURL]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (responseData)
    {
        NSArray *response =[NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if ([response count] > 0)
        {
            NSDictionary *responseDict = response[0];
            _bridgeIP = [NSURL URLWithString:responseDict[internalIPAddressKey]];
            [[NSUserDefaults standardUserDefaults] setObject:[_bridgeIP absoluteString] forKey:bridgeIPKey];
        }
    }
    else
    {
        _bridgeIP = nil;
    }
    return _bridgeIP;
}

- (NSURL *)bridgeBaseURL
{
    NSURL *base = nil;
    if (self.bridgeIP)
    {
        base = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/", self.bridgeIP]];
    }
    return base;
}

- (NSURL *)bridgeBaseURLWithUsername
{
    NSURL *baseWithUsername = nil;
    if (self.username && [self bridgeBaseURL])
    {
        baseWithUsername = [NSURL URLWithString:[NSString stringWithFormat:@"%@/", self.username] relativeToURL:[self bridgeBaseURL]];
    }
    return baseWithUsername;
}

#pragma mark Public Light methods

/*! Returns a HueLight object with a given unique ID.
 *\param ID An NSString with the ID value of a light. IDs can be obtained from
 the delegate.
 *\returns A HueLight object relating to the unique ID.
 */
- (HueLight *)lightWithID:(NSString *)ID
{
    for (HueLight *light in self.lights) {
        if ([light.uniqueID isEqualToString:ID])
            return light;
    }
    return nil;
}

/*! Returns a HueLight object with a given name.
 *\param ID An NSString with the name value of a light.
 *\returns A HueLight object relating to the name.
 */
- (HueLight *)lightWithName:(NSString *)name
{
    for (HueLight *light in self.lights) {
        if ([light.name isEqualToString:name])
        {
            return light;
        }
    }
    return nil;
}

#pragma mark Authentication and Reachability methods

/*! Searches for, and attempts to authenticate with, a bridge, delegating tasks
 back as necessary. */
- (void)searchForBridge
{
    // We have no bridge, delegate back to menu bar item
    if (![self bridgeBaseURL])
    {
        NSLog(@"Bridge not found, delegating to %@", self.delegate);
        [self.delegate bridgeNotFound];
    }
    // We have the bridge but no username
    else if (!self.username)
    {
        NSLog(@"No username found");
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"newdeveloper" relativeToURL:[self bridgeBaseURL]]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *authenticationData, NSError *error) {
            if (authenticationData)
            {
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:authenticationData options:0 error:&error][0];
                NSDictionary *errorDict = responseDict[errorKey];
                if (errorDict)
                {
                    NSString *description = errorDict[descriptionKey];
                    if (description)
                    {
                        // Make user press the link button
                        [self.delegate bridgeRequiresUserAuthentication:[[self bridgeIP] absoluteString] completion:^{
                            NSMutableDictionary *authDict = [NSMutableDictionary dictionaryWithDictionary:@{@"devicetype": @"WarningLights"}];
                            NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:[self bridgeBaseURL]];
                            NSError *authError = nil;
                            NSData *authData = [NSJSONSerialization dataWithJSONObject:authDict options:0 error:&authError];
                            [authRequest setHTTPMethod:@"POST"];
                            [authRequest setHTTPBody:authData];
                            
                            [NSURLConnection sendAsynchronousRequest:authRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *authResponseData, NSError *authError) {
                                if (authResponseData)
                                {
                                    NSDictionary *authResponseDict = [NSJSONSerialization JSONObjectWithData:authResponseData options:0 error:&authError][0];
                                    NSDictionary *success = authResponseDict[successKey];
                                    if (success)
                                    {
                                        self.username = success[usernameKey];
                                        NSLog(@"Successfully authenticated");
                                        [self.delegate bridgeAuthenticated:[[self bridgeIP] absoluteString]];
                                        [self syncLights];
                                    }
                                    else
                                    {
                                        // Attempt again, network connection must have been lost.
                                        [self searchForBridge];
                                    }
                                }
                            }];
                        }];
                    }
                }
            }
        }];
    }
    // We have the bridge and a username
    else if (self.username)
    {
        BOOL usernameIsAuthenticated = [self isConnectedToBridge];
        if (usernameIsAuthenticated)
        {
            NSLog(@"Bridge found + authenticated");
            [self.delegate bridgeAuthenticated:[[self bridgeIP] absoluteString]];
            [self syncLights];
        }
        else
        {
            // Need to reauthenticate as user has revoked permission for that username
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultSettingsKey];
            [self searchForBridge];
        }
    }
}

/*! Returns the connection status to the bridge. 
 *\returns A BOOL corresponding to the connection status. If we can successfully 
            query the bridge for a set of whitelist username values, and the 
            current username exists in the set of values, we are connected.
 */
- (BOOL)isConnectedToBridge
{
    NSDictionary *config = [self getConfiguration];
    NSDictionary *whitelist = [config valueForKey:whitelistKey];
    NSLog(@"%@", whitelist);
    return [whitelist valueForKey:self.username] != nil;
}

/*! Returns the bridge's current configuration by making an API request.
 *\returns An NSDictionary parsed from the JSON representation of its configuration.
 */
- (NSDictionary *)getConfiguration
{
    if (![self bridgeBaseURL])
        return nil;
    NSURLRequest *configRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"config" relativeToURL:[self bridgeBaseURLWithUsername]]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *configuration = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&response error:&error];
    if (configuration)
        return [NSJSONSerialization JSONObjectWithData:configuration options:0 error:&error];
    else
        return nil;
}

/*! Syncronises the HueController internal state with the set of lights available
    to the Philips Hue bridge. */
- (void)syncLights
{
    if (self.username)
    {
        NSURLRequest *lightRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"lights" relativeToURL:[self bridgeBaseURLWithUsername]]];
        [NSURLConnection sendAsynchronousRequest:lightRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *lightData, NSError *error) {
            if (lightData)
            {
                self.lights = nil;
                NSDictionary *lightDict = [NSJSONSerialization JSONObjectWithData:lightData options:0 error:nil];
                // Add to internal state
                for (NSString *key in [lightDict allKeys])
                {
                    NSDictionary *lightState = lightDict[key];
                    HueLight *light = [[HueLight alloc] initWithName:lightState[nameKey] uniqueID:key delegate:self];
                    [self.lights addObject:light];
                }
                // Delegate the discovery of lights
                if ([self.delegate respondsToSelector:@selector(lightsFound:)])
                {
                    [self.delegate lightsFound:self.lights];
                }
            }
        }];
    }
}

@end
