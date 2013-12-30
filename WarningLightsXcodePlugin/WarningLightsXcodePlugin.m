//
//  WarningLightsXcodePlugin.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import "WarningLightsXcodePlugin.h"
#import "WLMenuItemView.h"
#import "HueController.h"

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
        [self setupMenuBarItem];
        [hueController searchForBridge];
        hueController = [[HueController alloc] initWithDelegate:self];
        selectedLights = [NSMutableArray array];
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
    // Save the authentication block in the case where the user chooses to authenticate.
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
    NSDictionary *defaultSettings = [[NSUserDefaults standardUserDefaults] objectForKey:defaultSettingsKey];
    NSArray *ids = defaultSettings[selectedLightsKey];
    NSLog(@"%@", ids);
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
        NSMenuItem *lightItem = [[NSMenuItem alloc] initWithTitle:light.name action:@selector(lightSelected:) keyEquivalent:@""];
        WLMenuItemView *itemView = [[WLMenuItemView alloc] init];
        [itemView.nameLabel setStringValue:light.name];
        NSLog(@"%@", NSStringFromRect(itemView.nameLabel.frame));
        [lightItem setView:itemView];
        [lightItem setTarget:self];
        [self.warningLightsItem.submenu insertItem:lightItem atIndex:[self.warningLightsItem.submenu numberOfItems]];
        if ([ids containsObject:light.uniqueID])
            [selectedLights addObject:light];
        
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
- (void)lightSelected:(NSMenuItem *)lightMenuItem
{
    HueLight *light = [hueController lightWithName:lightMenuItem.title];
    if (light)
    {
        // Toggle light
        if ([selectedLights containsObject:light])
        {
            [selectedLights removeObject:light];
            [self removeSelectedLight:light];
        }
        else
        {
            [selectedLights addObject:[hueController lightWithName:lightMenuItem.title]];
            [self addSelectedLight:light];
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
- (void)addSelectedLight:(HueLight *)light
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:defaultSettingsKey] mutableCopy];
    NSMutableArray *lights = [defaultSettings[selectedLightsKey] mutableCopy];
    [lights addObject:light.uniqueID];
    
    defaultSettings[selectedLightsKey] = lights;
    
    [defaults setObject:defaultSettings forKey:defaultSettingsKey];
}

/*! Removes a persisted selected light in NSUserDefaults.
 *\param light The light to remove from the NSUserDefaults.
 */
- (void)removeSelectedLight:(HueLight *)light
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:defaultSettingsKey] mutableCopy];
    NSMutableArray *lights = [defaultSettings[selectedLightsKey] mutableCopy];
    [lights removeObject:light.uniqueID];
    
    defaultSettings[selectedLightsKey] = lights;
    
    [defaults setObject:defaultSettings forKey:defaultSettingsKey];
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
        self.authenticationBlock();
    }
}

#pragma mark NSUserInterfaceValidationProtocol

- (BOOL)validateUserInterfaceItem:(NSMenuItem <NSValidatedUserInterfaceItem>*)item
{
    if ([item action] == @selector(lightSelected:))
    {
        if ([item respondsToSelector:@selector(setState:)])
        {
            // Manage checkbox
            if ([selectedLights containsObject:[hueController lightWithName:item.title]])
                [item setState:NSOnState];
            else
                [item setState:NSOffState];
        }
    }
    return YES;
}

- (void)buildOperationDidStop:(NSNotification *)notification
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    // Grab the total number of errors from the build
    id buildLog = [notification.object performSelector:@selector(buildLog)];
    uint64_t errors = (uint64_t)[buildLog performSelector:@selector(totalNumberOfErrors)];
        
#pragma clang diagnostic pop
    
    if (errors > 0)
    {
        [selectedLights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            HueLight *light = (HueLight *)obj;
            [light syncWithCompletionBlock:^{
                // Save previous light state
                [light pushState];
                // Perform changes all at once
                [light commitStateChanges:^{
                    /* Sets a light on, to maximum brightness and saturation,
                       to hue: 0 (Red) for 2 seconds */
                    [light setOn:YES];
                    [light setHue:0];
                    [light setTransitionTime:20];
                    [light setBrightness:255];
                    [light setSaturation:255];
                    [light setAlert:HueLightAlertTypeNone];
                    [light setEffect:HueLightEffectTypeNone];
                }];
                // Revert to previous state over 2 seconds
                [light popStateWithTransitionTime:20];
            }];
        }];
    }
}

@end
