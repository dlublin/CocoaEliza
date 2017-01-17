#import <Cocoa/Cocoa.h>
#import "ELZDoctor.h"








@interface AppDelegate : NSObject <NSApplicationDelegate>	{

	IBOutlet NSPopUpButton		*languagePopUpButton;
	
	IBOutlet NSScrollView		*patientTextEntryScrollView;
	IBOutlet NSTextField		*patientTextEntry;
	IBOutlet NSTextView			*sessionTextView;
	
	IBOutlet ELZDoctor			*doctor;

}

- (IBAction) newSessionMenuUsed:(id)sender;
- (IBAction) languagePopUpButtonUsed:(id)sender;
- (IBAction) patientTextEntryUsed:(id)sender;
- (void) updateSessionTextView;

@end

