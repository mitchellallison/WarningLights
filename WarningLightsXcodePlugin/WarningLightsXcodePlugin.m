//
//  WarningLightsXcodePlugin.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import "WarningLightsXcodePlugin.h"
#import "HueController.h"
#import "WLMenuItem.h"

@interface WarningLightsXcodePlugin () <NSMenuDelegate>

@property (strong) NSMenuItem *bridgeIPField;
@property (strong) NSMenuItem *warningLightsItem;
@property (strong) NSMenuItem *connectButton;
@property (strong) NSMenuItem *searchForBridgeItem;

@property (strong) NSMenuItem *lightSeperator;

@property (strong) void (^authenticationBlock)();

@end

@implementation WarningLightsXcodePlugin

static WarningLightsXcodePlugin *plugin;
static HueController *hueController = nil;
static NSMutableArray *selectedLights = nil;
static NSMutableDictionary *lightOptionsMap = nil;

static const uint16_t redHue = 0;
static const uint16_t orangeHue = 8738;
static const uint16_t blueHue = 46920;
static const uint16_t greenHue = 26000;

/*! Class method called on plugin at launch.
 *\param bundle The NSBundle relating to the plug-in.
 */
+ (void)pluginDidLoad:(NSBundle *)bundle
{
    plugin = [[self alloc] initWithBundle:bundle];
}

/*! Initialises the plug-in.
 *\param bundle The NSBundle relating to the plug-in.
 *\returns An initialised WarningLightsXcodePlugin object.
 */
- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init])
    {
        // Whenever a project is launched, register for notifications from IDEBuildOperationDidStopNotification, and
        // act on the result
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(buildOperationDidStop:)
                                                     name:@"IDEBuildOperationDidStopNotification"
                                                   object:nil];
        
        if ([[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] isEqualToString:@"1.1"] &&
            ![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunchCompletedVersion1.1"])
        {
            NSLog(@"First launch!");
            
            NSDictionary *defaultSettings = [[NSUserDefaults standardUserDefaults] objectForKey:defaultSettingsKey];
            if (defaultSettings)
            {
                // WarningLights 1.0 has previously been launched and used.
                NSArray *selectedLights = defaultSettings[selectedLightsKey];
                
                // Set the error toggle for all previously selected lights
                NSMutableDictionary *lightOptions = [NSMutableDictionary dictionary];
                
                for (HueLight *light in selectedLights)
                {
                    [lightOptions setObject:@(WLMenuItemToggleTypeError) forKey:light.uniqueID];
                }
                
                // Initialise the new settings.
                NSDictionary *warningLightsSettings = @{selectedLightsKey: selectedLights, lightOptionsKey: lightOptions};
                
                // Store the new settings.
                [[NSUserDefaults standardUserDefaults] setObject:warningLightsSettings forKey:warningLightsSettingsKey];
                
                // Change the old structure.
                [[NSUserDefaults standardUserDefaults] setObject:@{usernameKey: defaultSettings[usernameKey]} forKey:defaultSettingsKey];
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunchCompletedVersion1.1"];
        }
        
        [self setupMenuBarItem];
        [hueController searchForBridge];
        hueController = [[HueController alloc] initWithDelegate:self];
        selectedLights = [NSMutableArray array];
        lightOptionsMap = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (NSBundle *)bundle
{
    return [NSBundle bundleForClass:self];
}

#pragma mark HueControllerDelegate methods & Helpers

/*! Convinience method used to delegate bridge searching to the HueController. */
- (void)searchForBridge
{
    [hueController searchForBridge];
}

- (void)bridgeNotFound
{
    [self.warningLightsItem.submenu removeAllItems];
    [self.warningLightsItem.submenu addItem:self.bridgeIPField];
    [self.bridgeIPField setTitle:@"Bridge: Not found"];
    if (self.searchForBridgeItem.menu == nil)
    {
        self.searchForBridgeItem = [[NSMenuItem alloc] initWithTitle:@"Search for bridge" action:@selector(searchForBridge) keyEquivalent:@""];
        self.searchForBridgeItem.target = self;
        [self.searchForBridgeItem setEnabled:YES];
        [self.warningLightsItem.submenu addItem:self.searchForBridgeItem];
        [self.bridgeIPField.view setNeedsDisplay:YES];
    }
    // Remove any previous light preferences
    [selectedLights removeAllObjects];
}

- (void)bridgeRequiresUserAuthentication:(NSString *)bridgeIP completion:(void (^)())completion
{
    if (self.searchForBridgeItem)
    {
        [self.warningLightsItem.submenu removeItem:self.searchForBridgeItem];
        self.searchForBridgeItem = nil;
    }
    if (self.connectButton.menu == nil)
    {
        self.connectButton = [[NSMenuItem alloc] initWithTitle:@"Connect" action:@selector(connectToBridge:) keyEquivalent:@""];
        [self.connectButton setTarget:self];
        [self.connectButton setEnabled:YES];
        [self.warningLightsItem.submenu insertItem:self.connectButton atIndex:[self.warningLightsItem.submenu indexOfItem:self.bridgeIPField] + 1];
    }
    // Save the authentication block for when the user chooses to authenticate.
    self.authenticationBlock = completion;
    [self.bridgeIPField setTitle:[NSString stringWithFormat:@"Bridge: %@", bridgeIP]];
}

- (void)bridgeAuthenticated:(NSString *)bridgeIP
{
    if (self.searchForBridgeItem)
    {
        [self.warningLightsItem.submenu removeItem:self.searchForBridgeItem];
        self.searchForBridgeItem = nil;
    }
    if (self.connectButton)
    {
        [self.warningLightsItem.submenu removeItem:self.connectButton];
        self.connectButton = nil;
    }
    [self.bridgeIPField setTitle:[NSString stringWithFormat:@"Bridge: %@", bridgeIP]];
}

- (void)lightsFound:(NSArray *)lights
{
    NSDictionary *defaultSettings = [[NSUserDefaults standardUserDefaults] objectForKey:warningLightsSettingsKey];
    NSArray *ids = defaultSettings[selectedLightsKey];
    NSLog(@"IDs: %lu", [ids count]);
    lightOptionsMap = [defaultSettings[lightOptionsKey] mutableCopy];
    if (self.lightSeperator.menu != nil)
    {
        for (NSInteger i = [self.warningLightsItem.submenu indexOfItem:self.lightSeperator] + 1; i < [self.warningLightsItem.submenu numberOfItems]; i++)
        {
            [self.warningLightsItem.submenu removeItemAtIndex:i];
        }
    }
    else
    {
        self.lightSeperator = [NSMenuItem separatorItem];
        [self.warningLightsItem.submenu insertItem:self.lightSeperator atIndex:[self.warningLightsItem.submenu numberOfItems]];
    }
    
    for (HueLight *light in lights)
    {
        // Add the lights to the menu.
        WLMenuItem *lightItem = [[WLMenuItem alloc] initWithTitle:light.name action:@selector(lightSelectionChangedWithItem:) keyEquivalent:@""];
        [lightItem setTarget:self];
        [self.warningLightsItem.submenu insertItem:lightItem atIndex:[self.warningLightsItem.submenu numberOfItems]];
        if ([ids containsObject:light.uniqueID])
        {
            [selectedLights addObject:light];
            [lightItem setState:[[lightOptionsMap objectForKey:light.uniqueID] integerValue]];
        }
        
        [lightItem.view layoutSubtreeIfNeeded];
    }
}

#pragma mark NSMenu delegate methods

/*! Sets up the menu bar item and subsequent submenus for Warning Lights. */
- (void)setupMenuBarItem
{
    NSMenuItem *productMenuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
    if (productMenuItem)
    {
        self.warningLightsItem = [[NSMenuItem alloc] initWithTitle:@"Warning Lights" action:nil keyEquivalent:@""];
        self.warningLightsItem.submenu = [[NSMenu alloc] initWithTitle:@"Warning Lights"];
        
        self.bridgeIPField = [[NSMenuItem alloc] initWithTitle:@"Bridge: Searching..." action:nil keyEquivalent:@""];
        
        [productMenuItem.submenu setDelegate:self];
        [productMenuItem.submenu insertItem:[NSMenuItem separatorItem] atIndex:[productMenuItem.submenu numberOfItems]];
        [productMenuItem.submenu insertItem:self.warningLightsItem atIndex:[productMenuItem.submenu numberOfItems]];
        [self.warningLightsItem.submenu addItem:self.bridgeIPField];
    }
}

/*! Select a light from the NSMenu.
 *\param lightMenuItem The selected item.
 */
- (void)lightSelectionChangedWithItem:(WLMenuItem *)lightMenuItem
{
    HueLight *light = [hueController lightWithName:lightMenuItem.title];
    NSInteger state = lightMenuItem.state;
    if (light)
    {
        // Toggle light
        if ([selectedLights containsObject:light])
        {
            assert([lightOptionsMap objectForKey:light.uniqueID]);
            if (state == WLMenuItemToggleTypeNone)
            {
                [selectedLights removeObject:light];
                [lightOptionsMap removeObjectForKey:light.uniqueID];
                [self removeSelectedLight:light];
            }
            else
            {
                [lightOptionsMap setObject:@(state) forKey:light.uniqueID];
                [self updateChangedState:@(state) forLight:light.uniqueID];
            }
        }
        else
        {
            if (state != WLMenuItemToggleTypeNone)
            {
                [selectedLights addObject:light];
                [lightOptionsMap setObject:@(state) forKey:light.uniqueID];
                [self addSelectedLight:light withState:@(state)];
            }
        }
    }
    else
    {
        // The light is no longer reachable, delegate the search to the HueController.
        [hueController searchForBridge];
    }
}

/*! Persists a selected light in NSUserDefaults to maintain choice between app launches.
 *\param light The light to add to the NSUserDefaults.
 */
- (void)addSelectedLight:(HueLight *)light withState:(NSNumber *)state
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:warningLightsSettingsKey] mutableCopy];
    NSMutableArray *lights = [defaultSettings[selectedLightsKey] mutableCopy];
    [lights addObject:light.uniqueID];
    
    defaultSettings[selectedLightsKey] = lights;
    
    NSMutableDictionary *options = [defaultSettings[lightOptionsKey] mutableCopy];
    [options setObject:state forKey:light.uniqueID];
    
    defaultSettings[lightOptionsKey] = options;
    
    [defaults setObject:defaultSettings forKey:warningLightsSettingsKey];
}

- (void)updateChangedState:(NSNumber *)state forLight:(NSString *)light
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:warningLightsSettingsKey] mutableCopy];
    NSMutableDictionary *options = [defaultSettings[lightOptionsKey] mutableCopy];
    [options setObject:state forKey:light];
    
    defaultSettings[lightOptionsKey] = options;
    
    [defaults setObject:defaultSettings forKey:warningLightsSettingsKey];
}

/*! Removes a persisted selected light in NSUserDefaults.
 *\param light The light to remove from the NSUserDefaults.
 */
- (void)removeSelectedLight:(HueLight *)light
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:warningLightsSettingsKey] mutableCopy];
    NSMutableArray *lights = [defaultSettings[selectedLightsKey] mutableCopy];
    [lights removeObject:light.uniqueID];
    
    defaultSettings[selectedLightsKey] = lights;
    
    NSMutableDictionary *options = [defaultSettings[lightOptionsKey] mutableCopy];
    [options removeObjectForKey:light.uniqueID];
    
    defaultSettings[lightOptionsKey] = options;
    
    [defaults setObject:defaultSettings forKey:warningLightsSettingsKey];
}

/*! Displays an NSAlert, prompting the user to authenticate with the bridge.
 *\param item The menu item the user has pressed to initiate the authentication.
 */
- (void)connectToBridge:(NSMenuItem *)item
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Press the link button on your Philips Hue bridge within the next 30 seconds." defaultButton:@"Done" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(userDismissedAuthenticationAlert:returnCode:contextInfo:) contextInfo:nil];
}

#pragma mark Bridge Authentication

- (void)userDismissedAuthenticationAlert:(NSAlert *)alert returnCode:(NSInteger)code contextInfo:(void*)info
{
    if (code == NSAlertDefaultReturn)
    {
        // Authenticate with the previously saved block.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@{selectedLightsKey: [NSArray array], lightOptionsKey: [NSDictionary dictionary]} forKey:warningLightsSettingsKey];
        self.authenticationBlock();
    }
}

- (void)buildOperationDidStop:(NSNotification *)notification
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    // Grab the total number of errors from the build
    id buildLog = [notification.object performSelector:@selector(buildLog)];
    uint64_t errors = (uint64_t)[buildLog performSelector:@selector(totalNumberOfErrors)];
    uint64_t warnings = (uint64_t)[buildLog performSelector:@selector(totalNumberOfWarnings)];
    uint64_t analyzed = (uint64_t)[buildLog performSelector:@selector(totalNumberOfAnalyzerResults)];
    
    
#pragma clang diagnostic pop

    [selectedLights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HueLight *light = (HueLight *)obj;

        WLMenuItemToggleType options = [[lightOptionsMap objectForKey:light.uniqueID] integerValue];
        
        if (errors > 0 && ((options & WLMenuItemToggleTypeError) == WLMenuItemToggleTypeError))
        {
            [light syncWithCompletionBlock:^{
                // Save previous light state
                [light pushState];

                [self fadeLight:light toHue:redHue sat:255 bri:255 overTransitionTime:20];
                
                [light popStateWithTransitionTime:20];
            }];
        }
        
        if (warnings > 0 && ((options & WLMenuItemToggleTypeWarning) == WLMenuItemToggleTypeWarning))
        {
            [light syncWithCompletionBlock:^{
                // Save previous light state
                [light pushState];

                [self fadeLight:light toHue:orangeHue sat:255 bri:255 overTransitionTime:20];
                
                [light popStateWithTransitionTime:20];
            }];
        }
        
        if (analyzed > 0 && ((options & WLMenuItemToggleTypeAnalyze) == WLMenuItemToggleTypeAnalyze))
        {
            [light syncWithCompletionBlock:^{
                // Save previous light state
                [light pushState];

                [self fadeLight:light toHue:blueHue sat:255 bri:255 overTransitionTime:20];
                
                [light popStateWithTransitionTime:20];
            }];
        }
        
        if (errors + warnings + analyzed == 0 && ((options & WLMenuItemToggleTypeSuccess) == WLMenuItemToggleTypeSuccess))
        {
            [light syncWithCompletionBlock:^{
                // Save previous light state
                [light pushState];
                
                [self fadeLight:light toHue:greenHue sat:255 bri:255 overTransitionTime:20];
                
                [light popStateWithTransitionTime:20];
            }];
        }
    }];
}

- (void)fadeLight:(HueLight *)light toHue:(uint16_t)hue sat:(uint8_t)sat bri:(uint8_t)bri overTransitionTime:(uint16_t)time
{
    // Perform changes all at once
    [light commitStateChanges:^{
        /* Sets a light on, to maximum brightness and saturation,
         to hue for time/10 seconds */
        [light setOn:YES];
        [light setHue:hue];
        [light setTransitionTime:time];
        [light setBrightness:bri];
        [light setSaturation:sat];
        [light setAlert:HueLightAlertTypeNone];
        [light setEffect:HueLightEffectTypeNone];
    }];
}

@end
