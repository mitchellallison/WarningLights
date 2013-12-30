//
//  WLMenuItemView.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison on 26/12/2013.
//
//

#import "WLMenuItemView.h"
#import "WLMenuItemViewToggle.h"
#import "NSColor+WLColors.h"

static NSString *const WLMenuItemViewToggleTypeKey = @"WLMenuItemViewToggleType";
static NSString *const WLToggleKey = @"WLToggleKey";

typedef NS_ENUM(NSInteger, WLMenuItemViewToggleType)
{
    WLMenuItemViewToggleTypeError,
    WLMenuItemViewToggleTypeWarning,
    WLMenuItemViewToggleTypeAnalyze,
    WLMenuItemViewToggleTypeSuccess,
};

@interface WLMenuItemView ()

@property (strong) WLMenuItemViewToggle *errorToggle;
@property (strong) WLMenuItemViewToggle *warningToggle;
@property (strong) WLMenuItemViewToggle *analyzeToggle;
@property (strong) WLMenuItemViewToggle *successToggle;

@property (strong, nonatomic) NSMutableSet *toggleTrackingAreas;

@property (strong) NSDictionary *currentHoveredToggleInfo;

@property NSTextField *descriptionLabel;

@end

@implementation WLMenuItemView

- (instancetype)init
{
    if (self = [super init])
    {
        self.nameLabel = [[NSTextField alloc] init];
        [self.nameLabel setEditable:NO];
        [self.nameLabel setBezeled:NO];
        [self.nameLabel setDrawsBackground:NO];
        [self.nameLabel setSelectable:NO];
        [self.nameLabel setFont:[NSFont menuFontOfSize:14]];
        
        [self addSubview:self.nameLabel];
        
        self.descriptionLabel = [[NSTextField alloc] init];
        [self.descriptionLabel setEditable:NO];
        [self.descriptionLabel setBezeled:NO];
        [self.descriptionLabel setDrawsBackground:NO];
        [self.descriptionLabel setSelectable:NO];
        [self.descriptionLabel setFont:[NSFont labelFontOfSize:[NSFont labelFontSize]]];
        [self.descriptionLabel setTextColor:[NSColor grayColor]];
        [self.descriptionLabel setStringValue:@""];
        
        [self addSubview:self.descriptionLabel];
        
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
  
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.errorToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.warningToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.analyzeToggle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.successToggle setTranslatesAutoresizingMaskIntoConstraints:NO];

        NSView *s1 = [[NSView alloc] init];
        NSView *s2 = [[NSView alloc] init];
        NSView *s3 = [[NSView alloc] init];
                
        [self addSubview:s1];
        [self addSubview:s2];
        [self addSubview:s3];
        
        [s1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [s2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [s3 setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSArray *heightConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel]-4-[_errorToggle]-4-[_descriptionLabel]-4-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel, _errorToggle, _descriptionLabel)];
        NSArray *labelWidthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[_nameLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)];
        NSArray *toggleWidthConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[e][s1(>=0)][w][s2(==s1)][a][s3(==s1)][s]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"e": _errorToggle, @"w": _warningToggle, @"a": _analyzeToggle, @"s": _successToggle, @"s1": s1, @"s2": s2, @"s3": s3}];
        NSLayoutConstraint *centerDescriptionConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        
        [self addConstraints:heightConstraint];
        [self addConstraints:labelWidthConstraint];
        [self addConstraints:toggleWidthConstraint];
        [self addConstraint:centerDescriptionConstraint];
        
    }
    return self;
}

- (NSMutableSet *)toggleTrackingAreas
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _toggleTrackingAreas = [[NSMutableSet alloc] initWithCapacity:4];
    });
    return _toggleTrackingAreas;
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
    for (NSTrackingArea *area in self.trackingAreas)
    {
        [self removeTrackingArea:area];
    }
    
    NSTrackingArea *errorArea = [[NSTrackingArea alloc] initWithRect:self.errorToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemViewToggleTypeKey: @(WLMenuItemViewToggleTypeError), WLToggleKey: self.errorToggle}];
    [self addTrackingArea:errorArea];
    NSTrackingArea *warningArea = [[NSTrackingArea alloc] initWithRect:self.warningToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemViewToggleTypeKey: @(WLMenuItemViewToggleTypeWarning), WLToggleKey: self.warningToggle}];
    [self addTrackingArea:warningArea];
    NSTrackingArea *analyzeArea = [[NSTrackingArea alloc] initWithRect:self.analyzeToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemViewToggleTypeKey: @(WLMenuItemViewToggleTypeAnalyze), WLToggleKey: self.analyzeToggle}];
    [self addTrackingArea:analyzeArea];
    NSTrackingArea *successArea = [[NSTrackingArea alloc] initWithRect:self.successToggle.frame options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow owner:self userInfo:@{WLMenuItemViewToggleTypeKey: @(WLMenuItemViewToggleTypeSuccess), WLToggleKey: self.successToggle}];
    [self addTrackingArea:successArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.currentHoveredToggleInfo = [[theEvent trackingArea] userInfo];
    [self alterDescriptionLabel];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSDictionary *info = [[theEvent trackingArea] userInfo];
    WLMenuItemViewToggle *toggle = [info objectForKey:WLToggleKey];
    [toggle setHighlighted:NO];
    [toggle setNeedsDisplay:YES];
    [self.descriptionLabel setStringValue:@""];
    self.currentHoveredToggleInfo = nil;
}

- (void)alterDescriptionLabel
{
    NSString *description;
    switch ([[self.currentHoveredToggleInfo objectForKey:WLMenuItemViewToggleTypeKey] integerValue]) {
        case WLMenuItemViewToggleTypeError:
            description = @"errors";
            break;
        case WLMenuItemViewToggleTypeWarning:
            description = @"warnings";
            break;
        case WLMenuItemViewToggleTypeAnalyze:
            description = @"analyze";
            break;
        case WLMenuItemViewToggleTypeSuccess:
            description = @"success";
            break;
        default:
            NSAssert(false, @"Mouse up in unfamiliar rectangle");
            break;
    }
    
    WLMenuItemViewToggle *toggle = [self.currentHoveredToggleInfo objectForKey:WLToggleKey];
    [toggle setHighlighted:YES];
    [toggle setNeedsDisplay:YES];
    NSString *result = toggle.state ? @"Cancel flash" : @"Tap to flash";
    description = [NSString stringWithFormat:@"%@ on %@.", result, description];
    [self.descriptionLabel setStringValue:description];
}

- (void)toggleButton:(WLMenuItemViewToggle*)toggle
{
    NSLog(@"Toggle");
    [self alterDescriptionLabel];
}

@end
