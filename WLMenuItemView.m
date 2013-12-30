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

typedef NS_ENUM(NSInteger, WLMenuItemViewToggleType)
{
    WLMenuItemViewToggleTypeError,
    WLMenuItemViewToggleTypeWarning,
    WLMenuItemViewToggleTypeAnalyze,
    WLMenuItemViewToggleTypeSuccess,
};

@interface WLMenuItemView ()

@property WLMenuItemViewToggle *errorToggle;
@property WLMenuItemViewToggle *warningToggle;
@property WLMenuItemViewToggle *analyzeToggle;
@property WLMenuItemViewToggle *successToggle;

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
        [self.descriptionLabel setStringValue:@"temp"];
        
        [self addSubview:self.descriptionLabel];
        
        self.errorToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelRed] strokeColor:[NSColor outlineRed]];
        [self addSubview:self.errorToggle];
        [self.errorToggle addTrackingRect:self.errorToggle.frame owner:self userData:(void*)CFBridgingRetain([NSNumber numberWithInteger:WLMenuItemViewToggleTypeError]) assumeInside:NO];
        
        self.warningToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelOrange] strokeColor:[NSColor outlineOrange]];
        [self addSubview:self.warningToggle];
        [self.warningToggle addTrackingRect:self.warningToggle.frame owner:self userData:(void*)CFBridgingRetain([NSNumber numberWithInteger:WLMenuItemViewToggleTypeWarning]) assumeInside:NO];
        
        self.analyzeToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelBlue] strokeColor:[NSColor outlineBlue]];
        [self addSubview:self.analyzeToggle];
        [self.analyzeToggle addTrackingRect:self.analyzeToggle.frame owner:self userData:(void*)CFBridgingRetain([NSNumber numberWithInteger:WLMenuItemViewToggleTypeAnalyze]) assumeInside:NO];
        
        self.successToggle = [[WLMenuItemViewToggle alloc] initWithFillColor:[NSColor pastelGreen] strokeColor:[NSColor outlineGreen]];
        [self addSubview:self.successToggle];
        [self.successToggle addTrackingRect:self.successToggle.frame owner:self userData:(void*)CFBridgingRetain([NSNumber numberWithInteger:WLMenuItemViewToggleTypeSuccess]) assumeInside:NO];
        
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

- (void)mouseUp:(NSEvent *)theEvent
{
    void* data = theEvent.userData;
    NSNumber *number = CFBridgingRelease(data);
    switch ([number integerValue]) {
        case WLMenuItemViewToggleTypeError:
            NSLog(@"Error");
            break;
        case WLMenuItemViewToggleTypeWarning:
            break;
        case WLMenuItemViewToggleTypeAnalyze:
            break;
        case WLMenuItemViewToggleTypeSuccess:
            break;
        default:
            NSAssert(false, @"Mouse up in unfamiliar rectangle");
            break;
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    
}

@end
