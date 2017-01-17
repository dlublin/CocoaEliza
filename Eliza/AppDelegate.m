#import "AppDelegate.h"





@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void) awakeFromNib	{
	[self newSessionMenuUsed:nil];
}

- (IBAction) newSessionMenuUsed:(id)sender	{
	NSLog(@"%s",__func__);
	NSString	*newSessionReply = [doctor startNewSession];
	if (newSessionReply != nil)	{
		NSLog(@"\t\t%@",newSessionReply);
	}
	[self updateSessionTextView];
	[patientTextEntry setStringValue:@""];
}

- (IBAction) languagePopUpButtonUsed:(id)sender	{
	NSLog(@"%s",__func__);
	NSString			*newLanguageSelection = [sender titleOfSelectedItem];
	NSString			*newPath = nil;
	if (newLanguageSelection != nil)	{
		newPath = [[NSBundle mainBundle] pathForResource:newLanguageSelection ofType:@"plist" inDirectory:@"Languages"];
	}
	else	{
		newPath = [[NSBundle mainBundle] pathForResource:@"English" ofType:@"plist" inDirectory:@"Languages"];
	}
	if (newPath != nil)	{
		NSLog(@"\t\tgoing to load %@",newPath);
		[doctor loadProfileFromPath:newPath];
	}
}

- (IBAction) patientTextEntryUsed:(id)sender	{
	//NSLog(@"%s",__func__);
	NSString	*newSessionReply = [doctor respondToString:[sender stringValue]];
	
	if (newSessionReply != nil)	{
		//NSLog(@"\t\tentered: %@",newSessionReply);
	}
	
	[self updateSessionTextView];
	[patientTextEntry setStringValue:@""];
}

- (void) updateSessionTextView	{
	//NSLog(@"%s",__func__);
	NSArray				*doctorLog = [doctor sessionHistoryCopy];
	NSMutableString		*logString = [NSMutableString stringWithCapacity:0];
	NSString			*patientName = [doctor patientName];
	for (NSDictionary *logEntry in doctorLog)	{
		NSString		*doctorString = [logEntry objectForKey:kELZDoctorResponseString];
		NSString		*patientString = [logEntry objectForKey:kELZPatientInputString];
		NSString		*dStringFormat = nil;
		NSString		*pStringFormat = nil;
		if (patientString != nil)
			pStringFormat = [NSString stringWithFormat:@"%@: %@\n",patientName,patientString];
		if (doctorString != nil)
			dStringFormat = [NSString stringWithFormat:@"Eliza: %@\n",doctorString];
		if (pStringFormat != nil)
			[logString appendString:pStringFormat];
		if (dStringFormat != nil)
			[logString appendString:dStringFormat];
		//NSLog(@"\t\t%@",logEntry);
	}
	[sessionTextView setString:logString];
	[sessionTextView scrollToEndOfDocument:nil];
}

@end
