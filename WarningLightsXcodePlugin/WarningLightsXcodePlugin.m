//
//  WarningLightsXcodePlugin.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import "WarningLightsXcodePlugin.h"
#import <objc/objc-runtime.h>
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
        // Whenever a project is launched, we swizzle the build methods and set
        // up the menu bar and HueController
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(swizzleBuildMethods:) name:@"PBXProjectDidOpenNotification" object:nil];
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
        [lightItem setTarget:self];
        [self.warningLightsItem.submenu insertItem:lightItem atIndex:[self.warningLightsItem.submenu numberOfItems]];
        if ([ids containsObject:light.uniqueID])
            [selectedLights addObject:light];
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

#pragma mark Swizzle & Class Dump methods

/*! Swizzles -lastBuilderDidFinish on IDEBuildOperation in order to be intercept
 * build phases.
 *\param notification The NSNotification used to signal the swizzle.
 */
- (void)swizzleBuildMethods:(NSNotification *)notification
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *applicationIdentifier = [bundle bundleIdentifier];
    
    if (![applicationIdentifier isEqualToString:@"com.apple.dt.Xcode"])
        return;
        
    Class class = NSClassFromString(@"IDEBuildOperation");
    performSwizzle(class, @selector(lastBuilderDidFinish), @selector(wlLastBuilderDidFinish), YES);
}

// Runtime funtime - Method swizzling function.
static BOOL performSwizzle(Class class, SEL original, SEL alternative, BOOL forInstance)
{
    // Get original method
	Method origMethod = class_getInstanceMethod(class, original);
	if (!origMethod) {
		NSLog(@"Original method %@ not found.", NSStringFromSelector(original));
		return NO;
	}
    
    // Get alternative method
	Method altMethod = class_getInstanceMethod(class, alternative);
	if (!alternative) {
		NSLog(@"Alternative method %@ not found.", NSStringFromSelector(alternative));
		return NO;
	}
    
    // Add both methods to the class
	class_addMethod(class,
					original,
					class_getMethodImplementation(class, original),
					method_getTypeEncoding(origMethod));
	class_addMethod(class,
					alternative,
					class_getMethodImplementation(class, alternative),
					method_getTypeEncoding(altMethod));
    
    //Swap implementations
	method_exchangeImplementations(class_getInstanceMethod(class, original), class_getInstanceMethod(class, alternative));
	return YES;
}

// Useful class dump for inspecting the runtime elements of Xcode classes.
- (void)dumpInfoFromClass:(Class)clazz
{
    u_int count;
    
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}

@end

@implementation NSObject (WarningLightsBuildPatch)

- (void)wlLastBuilderDidFinish
{
    // Grab the total number of errors from the build
    unsigned long long errors = (unsigned long long)[[self performSelector:@selector(buildLog)] performSelector:@selector(totalNumberOfErrors)];
    
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
    
    // Continue with existing implementation
    [self wlLastBuilderDidFinish];
}

@end
