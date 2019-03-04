///////////////////////////////////////////////////////////////////////
// vim: set filetype=objc :
//
// statusbar.m
//
// Jeff Buck
// Copyright 2019.
//


#import <Cocoa/Cocoa.h>

#import <sys/stat.h>
#include <stdlib.h>

const float WindowWidth = 1200.0f;
const float WindowHeight = 850.0f;

////////////////////////////////////////////////////////////////////////
//
// These are some UI convenience functions for creating a few common
// Cocoa AppKit controls. You can style many of these controls with
// different sizes, different fonts, etc. depending on your application
// but we'll keep it fairly simple for now.
//
NSSlider* UIMakeSlider(NSView* parent, float value, float minValue, float maxValue,
                       id target, SEL selector,
					   NSRect frame)
{
	NSSlider* slider = [NSSlider sliderWithValue:value minValue:minValue maxValue:maxValue
								 target:target action:selector];
	slider.frame = frame;
	[parent addSubview:slider];

	return slider;
}

NSButton* UIMakeCheckbox(NSView* parent, NSString* label, bool value,
                         id target, SEL selector,
			             NSRect frame)
{
	NSButton* cb = [NSButton buttonWithTitle:label target:target action:selector];
	cb.buttonType = NSButtonTypeSwitch;
	cb.state = value;
	cb.frame = frame;

	[parent addSubview:cb];

	return cb;
}


NSPopUpButton* UIMakeDropdown(NSView* parent, NSArray<NSString*>* choices, unsigned int defaultValue,
                              id target, SEL selector,
							  NSRect frame)
{
	NSPopUpButton* control = [[NSPopUpButton alloc] initWithFrame:frame pullsDown:NO];

	for (NSString* item in choices)
	{
		[control addItemWithTitle:item];
	}

	[parent addSubview:control];

	[control selectItemAtIndex:defaultValue];

	control.target = target;
	control.action = selector;

	return control;

}


NSTextField* UIMakeTextLabel(NSView* parent, NSString* value, NSRect frame)
{
	NSTextField* tf = [NSTextField labelWithString:value];
	tf.frame = frame;
	tf.editable = NO;
	[parent addSubview:tf];

	return tf;
}

NSColorWell* UIMakeColorWell(NSView* parent, float r, float g, float b, NSRect frame)
{
	NSColorWell* cw = [NSColorWell new];
	cw.frame = frame;
	[parent addSubview:cw];

	cw.color = [NSColor colorWithDeviceRed:r
									 green:g
									  blue:b
									 alpha:1.0f];
	return cw;
}

NSButton* UIMakeButton(NSView* parent, NSString* label,
                       id target, SEL selector,
					   NSRect frame)
{
	NSButton* button = [NSButton buttonWithTitle:label target:target action:selector];
	button.frame = frame;
	[parent addSubview:button];

	return button;
}

//
// End of UI convenience functions
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// The StatusBarViewController manages the contents of the popover
// content view that gets created when the status bar item is clicked
//
@interface StatusBarViewController : NSViewController

@property(nonatomic, retain)NSColorWell* colorWell;
@property(nonatomic, retain)NSSlider* sliderR;
@property(nonatomic, retain)NSSlider* sliderG;
@property(nonatomic, retain)NSSlider* sliderB;
@property(nonatomic, retain)NSTextField* sliderTextR;
@property(nonatomic, retain)NSTextField* sliderTextG;
@property(nonatomic, retain)NSTextField* sliderTextB;
@property(nonatomic, retain)NSButton* checkbox;
@property(nonatomic, retain)NSPopUpButton* dropdown;
@end


@implementation StatusBarViewController
@synthesize sliderR;
@synthesize sliderG;
@synthesize sliderB;
@synthesize sliderTextR;
@synthesize sliderTextG;
@synthesize sliderTextB;
@synthesize colorWell;
@synthesize checkbox;
@synthesize dropdown;


////////////////////////////////////////////////////////////////////////
// The following methods are actions that are invoked in response to
// interaction with a control such as a button, slider or dropdown.
//
- (void)setColorWell
{
	self.colorWell.color = [NSColor colorWithDeviceRed:sliderR.floatValue
												 green:sliderG.floatValue
												  blue:sliderB.floatValue
												 alpha:1.0f];
}

- (void)sliderRChanged:(NSSlider*)slider
{
	[self.sliderTextR setStringValue:[NSString stringWithFormat:@"R: %.2f", slider.floatValue]];
	[self setColorWell];
}

- (void)sliderGChanged:(NSSlider*)slider
{
	[self.sliderTextG setStringValue:[NSString stringWithFormat:@"G: %.2f", slider.floatValue]];
	[self setColorWell];
}

- (void)sliderBChanged:(NSSlider*)slider
{
	[self.sliderTextB setStringValue:[NSString stringWithFormat:@"B: %.2f", slider.floatValue]];
	[self setColorWell];
}


- (void)setColorRed:(float)red green:(float)green blue:(float)blue
{
	[sliderR setFloatValue:red];
	[sliderG setFloatValue:green];
	[sliderB setFloatValue:blue];

	[self sliderRChanged:sliderR];
	[self sliderGChanged:sliderG];
	[self sliderBChanged:sliderB];

	[self setColorWell];
}


- (void)resetRed:(id)sender
{
	#pragma unused(sender)

	[self setColorRed:1.0f green:0.0f blue:0.0f];
}


- (void)toggleCheckbox:(id)sender
{
	#pragma unused(sender)

	self.dropdown.enabled = self.checkbox.state;
}


- (void)dropdownSelected:(NSPopUpButton*)button
{
	NSLog(@"dropdown selection is '%@'", button.titleOfSelectedItem);

	NSString* item = button.titleOfSelectedItem;

	if ([item isEqualToString:@"Banana"])
	{
		[self setColorRed:1.0f green:1.0f blue:0.0f];
	}
	else if ([item isEqualToString:@"Blueberry"])
	{
		[self setColorRed:0.0f green:0.0f blue:1.0f];
	}
	else if ([item isEqualToString:@"Cherry"])
	{
		[self setColorRed:1.0f green:0.0f blue:0.0f];
	}
	else if ([item isEqualToString:@"Kiwi"])
	{
		[self setColorRed:0.0f green:1.0f blue:0.0f];
	}
	else if ([item isEqualToString:@"Lump of Coal"])
	{
		[self setColorRed:0.0f green:0.0f blue:0.0f];
	}
}

// End of control action methods
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// viewDidLoad is called once when the status bar item is selected for
// the first time. All of the controls are programmatically created at
// this time.
//
- (void)viewDidLoad
{
	[super viewDidLoad];

	NSLog(@"StatusBarViewController::viewDidLoad with bounds (%f, %f)",
			[self.view bounds].size.width,
			[self.view bounds].size.height);

	/////////////////////////////////////////////////////////////////////////
	//
	// Create a few example controls and wire up some actions.
	//
	// I would normally put these in a NSStackView or something appropriate
	// for easier autolayout. But for this simple demo, we'll hardcode the
	// layout and create the controls programmatically to look roughly like
	// this:
	//
	//  ┌─────────────────────────────────────────────────────────────┐
	//  │ ┌───────────────────┐  ┌──────────────────┐ ┌─────────────┐ │
	//  │ │                   │  │     NSSlider (R) │ │ NSTextField │ │
	//  │ │                   │  └──────────────────┘ └─────────────┘ │
	//  │ │                   │  ┌──────────────────┐ ┌─────────────┐ │
	//  │ │    NSColorWell    │  │     NSSlider (G) │ │ NSTextField │ │
	//  │ │                   │  └──────────────────┘ └─────────────┘ │
	//  │ │                   │  ┌──────────────────┐ ┌─────────────┐ │
	//  │ │                   │  │     NSSlider (B) │ │ NSTextField │ │
	//  │ └───────────────────┘  └──────────────────┘ └─────────────┘ │
	//  │                                                             │
	//  │ ┌───────────────────┐                                       │
	//  │ │ NSButton (Reset)  │                                       │
	//  │ └───────────────────┘                                       │
	//  │                                                             │
	//  │                                                             │
	//  │ ┌───────────────────┐  ┌───────────────────┐                │
	//  │ │NSButton (Checkbox)│  │   NSPopUpButton   │                │
	//  │ └───────────────────┘  └───────────────────┘                │
	//  │                                                             │
	//  │                                                             │
	//  │ ┌───────────────────┐                                       │
	//  │ │ NSButton (Quit)   │                                       │
	//  │ └───────────────────┘                                       │
	//  └─────────────────────────────────────────────────────────────┘
	//

	// A few layout parameters...
	float leftMargin = 20.0f;
	float verticalMargin = 20.0f;

	float colorWellSize = 80.0f;

	float sliderWidth = 120.0f;
	float sliderTextWidth = 60.0f;

	float controlHeight = 24.0f;
	float controlVerticalSpacing = 30.0f;


	float sliderStartX = 2 * leftMargin + colorWellSize;
	float sliderTextStartX = sliderStartX + sliderWidth + leftMargin;

	float startingY = [self.view bounds].size.height - 60.0f;
	float colorWellStartingY = [self.view bounds].size.height - colorWellSize - 2 * verticalMargin;
	float currentY = startingY;

	// Default to a red color in the ColorWell
	float defaultR = 1.0f;
	float defaultG = 0.0f;
	float defaultB = 0.0f;

	// ColorWell
	self.colorWell = UIMakeColorWell(self.view, defaultR, defaultG, defaultB,
					                 (NSRect){{leftMargin, colorWellStartingY}, {colorWellSize, colorWellSize}});

	// Red
	self.sliderR = UIMakeSlider(self.view,
	                            defaultR, 0.0, 1.0,
								self, @selector(sliderRChanged:),
	                            (NSRect){{sliderStartX, currentY}, {sliderWidth, controlHeight}});
	self.sliderTextR = UIMakeTextLabel(self.view,
	                                   [NSString stringWithFormat:@"R: %.2f", defaultR],
			                           (NSRect){{sliderTextStartX, currentY}, {sliderTextWidth, controlHeight}});
	currentY -= controlVerticalSpacing;

	// Green
	self.sliderG = UIMakeSlider(self.view,
	                            defaultG, 0.0, 1.0,
								self, @selector(sliderGChanged:),
	                            (NSRect){{sliderStartX, currentY}, {sliderWidth, controlHeight}});
	self.sliderTextG = UIMakeTextLabel(self.view,
	                                   [NSString stringWithFormat:@"G: %.2f", defaultG],
			                           (NSRect){{sliderTextStartX, currentY}, {sliderTextWidth, controlHeight}});
	currentY -= controlVerticalSpacing;

	// Blue
	self.sliderB = UIMakeSlider(self.view,
	                            defaultB, 0.0, 1.0,
								self, @selector(sliderBChanged:),
	                            (NSRect){{sliderStartX, currentY}, {sliderWidth, controlHeight}});
	self.sliderTextB = UIMakeTextLabel(self.view,
	                                   [NSString stringWithFormat:@"B: %.2f", defaultB],
			                           (NSRect){{sliderTextStartX, currentY}, {sliderTextWidth, controlHeight}});
	currentY -= 2 * controlVerticalSpacing;


	// Reset to Red color
	UIMakeButton(self.view, @"Reset Red", self, @selector(resetRed:),
	             (NSRect){{leftMargin, currentY}, {100.0f, controlHeight}});

	currentY -= 2 * controlVerticalSpacing;


	// Sample checkbox with toggling label
	self.checkbox = UIMakeCheckbox(self.view, @"Enable Dropdown", YES, self, @selector(toggleCheckbox:),
				                   (NSRect){{leftMargin, currentY}, {130.0f, controlHeight}});

	// Sample dropdown that will change the ColorWell
	NSArray<NSString*>* choices = @[ @"Banana", @"Blueberry", @"Cherry", @"Kiwi", @"Lump of Coal" ];

	self.dropdown = UIMakeDropdown(self.view, choices, 2, self, @selector(dropdownSelected:),
				                   (NSRect){{2 * leftMargin + 130.0f, currentY}, {100.0f, controlHeight}});

	currentY -= controlVerticalSpacing;

	// Quit button at the bottom
	UIMakeButton(self.view, @"Quit", [NSApplication sharedApplication], @selector(terminate:),
	             (NSRect){{leftMargin, verticalMargin}, {100.0f, controlHeight}});
}

- (void)loadView
{
	// Set the size of the popover content view
	self.view = [[NSView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 400.0f, 300.0f)];
}


- (id)init
{
	// Since we're not using a nib, we'll override the default initializer
	// and create our view contents programmatically.
	self = [super initWithNibName:nil bundle:nil];
	return self;
}

@end


////////////////////////////////////////////////////////////////////////
// ApplicationDelegate
//

@interface StatusBarAppDelegate : NSObject<NSApplicationDelegate, NSWindowDelegate>

@property(nonatomic, retain)NSPopover* popover;
@property(nonatomic, retain)NSStatusItem* statusItem;
@property(nonatomic, retain)id monitor;
@end


@implementation StatusBarAppDelegate

@synthesize popover;
@synthesize statusItem;
@synthesize monitor;


- (void)showPopover:(id)sender
{
	#pragma unused(sender)

	NSButton* button = self.statusItem.button;
	[self.popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMinY];

	// When we show a status bar item popover, we should dismiss it
	// whenever the mouse is clicked outside of our popover window.
	// A global event monitor will tell us when this happens.
	//
	// Normal mouse clicks inside our popover window are processed
	// normally and are not passed through this monitor.
	//
	// There is a nice article at
	// https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos
	// that explains more about global event monitoring.

	self.monitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseDown|NSEventMaskRightMouseDown
														  handler:^(NSEvent* event) {
											   					[self closePopover:event];
														  }];
}


- (void)closePopover:(id)sender
{
	[self.popover performClose:sender];
	[NSEvent removeMonitor:self.monitor];
	self.monitor = nil;
}


- (void)togglePopover:(id)sender
{
	NSLog(@"Toggling Popover");

	if (self.popover.isShown)
	{
		[self closePopover:sender];
	}
	else
	{
		[self showPopover:sender];
	}
}


////////////////////////////////////////////////////////////////////////
// This is a common place to initialize our part of the application.
// For a normal application, we might create a window and view here.
// In our special case, we'll create the NSStatusItem and add it to
// the system status bar.
//
- (void)applicationDidFinishLaunching:(id)sender
{
	#pragma unused(sender)

	NSLog(@"applicationDidFinishLaunching...");

	NSStatusItem* si = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	si.button.image = [NSImage imageNamed:@"StatusBar"]; // looks in Resources subdirectory
	si.button.image.template = YES; // support dark mode
	si.button.action = @selector(togglePopover:);

	self.statusItem = si;

	self.popover = [NSPopover new];
	self.popover.contentViewController = [[StatusBarViewController alloc] init];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	#pragma unused(sender)

	// Closing the popover will terminate the status bar app if this is set to YES
	return NO;
}


- (void)applicationWillTerminate:(NSApplication*)sender
{
	#pragma unused(sender)

	// Do any cleanup here
}

@end

//
// ApplicationDelegate
////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////
//
// This is mostly boilerplate code for a typical Cocoa application.
// We create our custom NSApplicationDelegate here.
int main(int argc, const char* argv[])
{
	#pragma unused(argc)
	#pragma unused(argv)

	@autoreleasepool
	{
	NSApplication* app = [NSApplication sharedApplication];
	[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

	StatusBarAppDelegate* appDelegate = [[StatusBarAppDelegate alloc] init];

	[app setDelegate:appDelegate];

	[NSApp finishLaunching];

	// If you want to debug autolayout, set this Bool to YES
	//[[NSUserDefaults standardUserDefaults] setBool:NO
	//       forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];

	[app run];
	}
}

