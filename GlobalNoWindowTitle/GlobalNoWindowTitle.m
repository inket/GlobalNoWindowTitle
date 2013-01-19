//
//  GlobalNoWindowTitle.m
//  GlobalNoWindowTitle
//
//  Created by inket on 19/01/2013.
//

#import "GlobalNoWindowTitle.h"

static GlobalNoWindowTitle* plugin = nil;

@implementation NSObject (GlobalNoWindowTitle)

#pragma mark NSThemeDocumentButtonCell's icon drawing method replacement

- (void)new_drawWithFrame:(struct CGRect)arg1 inView:(id)arg2 {
    [self new_drawWithFrame:NSMakeRect(arg1.origin.x, arg1.origin.y, arg1.size.width-20, arg1.size.height)
                     inView:arg2];
}

#pragma mark AppKit's NSWindow method replacement

- (void)new_setTitle:(NSString*)title {
    [self new_setTitle:@"			"]; // 3 TABs string to leave room for clickable area in document apps.
}

@end


@implementation GlobalNoWindowTitle

#pragma mark SIMBL methods and loading

+ (GlobalNoWindowTitle*)sharedInstance {
	if (plugin == nil)
		plugin = [[GlobalNoWindowTitle alloc] init];
	
	return plugin;
}

+ (void)load {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/SIMBL/Plugins/NoWindowIcon.bundle"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/SIMBL/Plugins/NoWindowTitle.bundle"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/SIMBL/Plugins/GlobalNoWindowIcon.bundle"])
	{
		NSLog(@"GlobalNoWindowTitle won't load because NoWindowIcon/GlobalNoWindowIcon/NoWindowTitle is installed.");
		return;
	}
    
	[[GlobalNoWindowTitle sharedInstance] loadPlugin];
	
	NSLog(@"GlobalNoWindowTitle loaded.");
}

- (void)loadPlugin {
    Class class = NSClassFromString(@"NSThemeDocumentButtonCell");
    Method new = class_getInstanceMethod(class, @selector(new_drawWithFrame:inView:));
    Method old = class_getInstanceMethod(class, @selector(drawWithFrame:inView:));
	method_exchangeImplementations(new, old);
    
	class = NSClassFromString(@"NSWindow");
	new = class_getInstanceMethod(class, @selector(new_setTitle:));
	old = class_getInstanceMethod(class, @selector(setTitle:));
	method_exchangeImplementations(new, old);
    
    for (NSWindow *window in [[NSApplication sharedApplication] windows])
        [window setTitle:@"			"];
}

@end