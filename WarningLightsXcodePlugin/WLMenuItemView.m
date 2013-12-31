//
//  WLMenuItem.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 26/12/2013.
//
//

#import "WLMenuItemView.h"
#import "WLMenuItemViewToggle.h"
#import "NSColor+WLColors.h"
#import "WLMenuConstants.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const WLMenuItemToggleTypeKey = @"WLMenuItemToggleType";
static NSString *const WLToggleKey = @"WLToggleKey";

@interface WLMenuItemView ()

@property NSInteger state;

@end

@interface WLMenuItemView ()

@property (strong) WLMenuItemViewToggle *errorToggle;
@property (strong) WLMenuItemViewToggle *warningToggle;
@property (strong) WLMenuItemViewToggle *analyzeToggle;
@property (strong) WLMenuItemViewToggle *successToggle;

@property (strong) NSDictionary *currentHoveredToggleInfo;

@property NSTextField *descriptionLabel;

- (void)toggleButton:(WLMenuItemViewToggle *)toggle;

@end

@implementation WLMenuItemView

- (instancetype)init
{
    if (self = [super init])
    {
        self.state = 0;
        
        // Create the name label
        self.nameLabel = [[NSTextField alloc] init];
        [self.nameLabel setEditable:NO];
        [self.nameLabel setBezeled:NO];
        [self.nameLabel setDrawsBackground:NO];
        [self.nameLabel setSelectable:NO];
        [self.nameLabel setFont:[NSFont menuFontOfSize:14]];
        
        [self addSubview:self.nameLabel];
        
        // Create the description label
        self.descriptionLabel = [[NSTextField alloc] init];
        [self.descriptionLabel setEditable:NO];
        [self.descriptionLabel setBezeled:NO];
        [self.descriptionLabel setSelectable:NO];
        [self.descriptionLabel setFont:[NSFont labelFontOfSize:[NSFont labelFontSize]]];
        [self.descriptionLabel setTextColor:[NSColor grayColor]];
        [self.descriptionLabel setStringValue:@""];
        [self.descriptionLabel setAlphaValue:0.0];
        
        [self addSubview:self.descriptionLabel];
        
        // Create the toggles
        self.errorToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelRed] strokeColor:[NSColor outlineRed]];
        [self.errorToggle setAction:@selector(toggleButton:)];
        [self.errorToggle setTarget:self];
        [self addSubview:self.errorToggle];
        
        self.warningToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelOrange] strokeColor:[NSColor outlineOrange]];
        [self.warningToggle setAction:@selector(toggleButton:)];
        [self.warningToggle setTarget:self];
        [self addSubview:self.warningToggle];

        self.analyzeToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelBlue] strokeColor:[NSColor outlineBlue]];
        [self.analyzeToggle setAction:@selector(toggleButton:)];
        [self.analyzeToggle setTarget:self];
        [self addSubview:self.analyzeToggle];
        
        self.successToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelGreen] strokeColor:[NSColor outlineGreen]];
        [self.successToggle setAction:@selector(toggleButton:)];
        [self.successToggle setTarget:self];
        [self addSubview:self.successToggle];
        
        // Set up layout constraints
        [self setupLayoutConstraints];
    }
    return self;
}

/*! Sets up the layout constraints for the subviews. */
- (void)setupLayoutConstraints
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.errorToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.warningToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.analyzeToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.successToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    // Spacer views
    NSView *s1 = [[NSView alloc] init];
    NSView *s2 = [[NSView alloc] init];
    NSView *s3 = [[NSView alloc] init];
    
    [self addSubview:s1];
    [self addSubview:s2];
    [self addSubview:s3];
    
    [s1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [s2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [s3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    // Set up vertical constraints
    NSArray *yConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel]-4-[_errorToggle]-4-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _errorToggle)];
    
    // Set up horizontal constraints
    NSArray *xConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_nameLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)];
    
    // Space out the toggles evenly.
    NSArray *toggleWidthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[e][s1(>=0)][w][s2(==s1)][a][s3(==s1)][s]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"e": _errorToggle, @"w": _warningToggle, @"a": _analyzeToggle, @"s": _successToggle, @"s1": s1, @"s2": s2, @"s3": s3}];
    
    // Set the description label to have the same center as the name label.
    NSLayoutConstraint *descriptionLabelX = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *descriptionLabelY = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    [self addConstraints:yConstraints];
    [self addConstraints:xConstraints];
    [self addConstraints:toggleWidthConstraint];
    [self addConstraints:@[descriptionLabelX, descriptionLabelY]];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self updateTrackingAreas];
}

- (void)setBounds:(NSRect)aRect
{
    [super setBounds:aRect];
    [self updateTrackingAreas];
}

- (void)updateTrackingAreas
{
    // Set up tracking areas for all of the toggles.
    
    for (NSTrackingArea *area in self.trackingAreas)
    {
        [self removeTrackingArea:area];
    }
    
    NSTrackingArea *errorArea = [[NSTrackingArea alloc] initWithRect:self.errorToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemToggleTypeKey: @(WLMenuItemToggleTypeError), WLToggleKey: self.errorToggle}];
    [self addTrackingArea:errorArea];
    NSTrackingArea *warningArea = [[NSTrackingArea alloc] initWithRect:self.warningToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemToggleTypeKey: @(WLMenuItemToggleTypeWarning), WLToggleKey: self.warningToggle}];
    [self addTrackingArea:warningArea];
    NSTrackingArea *analyzeArea = [[NSTrackingArea alloc] initWithRect:self.analyzeToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemToggleTypeKey: @(WLMenuItemToggleTypeAnalyze), WLToggleKey: self.analyzeToggle}];
    [self addTrackingArea:analyzeArea];
    NSTrackingArea *successArea = [[NSTrackingArea alloc] initWithRect:self.successToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemToggleTypeKey: @(WLMenuItemToggleTypeSuccess), WLToggleKey: self.successToggle}];
    [self addTrackingArea:successArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    // Store the current information and alter the description label.
    self.currentHoveredToggleInfo = [[theEvent trackingArea] userInfo];
    [self alterDescriptionLabel];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    // Set the highlight of the toggle to NO
    NSDictionary *info = [[theEvent trackingArea] userInfo];
    WLMenuItemViewToggle *toggle = [info objectForKey:WLToggleKey];
    [toggle setHighlighted:NO];
    [toggle setNeedsDisplay:YES];
    
    // Fade out the description label
    [NSAnimationContext beginGrouping];
    {
        [[NSAnimationContext currentContext] setDuration:0.25];
        [self.descriptionLabel.animator setAlphaValue:0.0];
        [self.nameLabel.animator setAlphaValue:1.0];
    }
    [NSAnimationContext endGrouping];
    [self.descriptionLabel setStringValue:@""];
    self.currentHoveredToggleInfo = nil;
}

/*! Alters the description label depending on what is being hovered over.
 */
- (void)alterDescriptionLabel
{
    // Get the type of toggle.
    NSString *description;
    switch ([[self.currentHoveredToggleInfo objectForKey:WLMenuItemToggleTypeKey] integerValue]) {
        case WLMenuItemToggleTypeError:
            description = @"errors";
            break;
        case WLMenuItemToggleTypeWarning:
            description = @"warnings";
            break;
        case WLMenuItemToggleTypeAnalyze:
            description = @"analyze";
            break;
        case WLMenuItemToggleTypeSuccess:
            description = @"success";
            break;
        default:
            NSAssert(false, @"Mouse up in unfamiliar rectangle");
            break;
    }
    
    // Change the highlight of the toggle.
    WLMenuItemViewToggle *toggle = [self.currentHoveredToggleInfo objectForKey:WLToggleKey];
    [toggle setHighlighted:YES];
    [toggle setNeedsDisplay:YES];
    
    // Alter the description label.
    NSString *result = toggle.state ? @"Cancel flash" : @"Tap to flash";
    description = [NSString stringWithFormat:@"%@ on %@.", result, description];
    [self.descriptionLabel setStringValue:description];
    
    // Fade in the description label.
    [NSAnimationContext beginGrouping];
    {
        [[NSAnimationContext currentContext] setDuration:0.25];
        [self.descriptionLabel.animator setAlphaValue:1.0];
        [self.nameLabel.animator setAlphaValue:0.0];
    }
    [NSAnimationContext endGrouping];
}

/*! Changes the state and alters the description label
 *\param toggle the WLMenuItemViewToggle that has been clicked.
 */
- (void)toggleButton:(WLMenuItemViewToggle *)toggle
{
    [self alterDescriptionLabel];
    if (self.currentHoveredToggleInfo)
    {
        WLMenuItemToggleType type = [[self.currentHoveredToggleInfo objectForKey:WLMenuItemToggleTypeKey] integerValue];
        self.state ^= type;
    }
}

/*! Updates the toggle with a given state.
 *\param state A WLMenuToggleType representing which options are switched on.
 */
- (void)updateWithState:(WLMenuItemToggleType)state
{
    self.state = state;
    NSArray *toggles = @[self.errorToggle, self.warningToggle, self.analyzeToggle, self.successToggle];
    
    for (WLMenuItemViewToggle *toggle in toggles)
    {
        if (state & 1)
        {
            [toggle setState:NSOnState];
        }
        state >>= 1;
    }
}

@end
