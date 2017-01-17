#import <Foundation/Foundation.h>


/*

	The markup for replies is as follows.
	--INPUT--, inserts the exact same input
	--OLDINPUT--, inserts some random old input
	--NAME--, inserts the patient name

*/


#define kELZPatientInputString @"kELZPatientInputString"
#define kELZDoctorResponseString @"kELZDoctorResponseString"



@interface ELZDoctor : NSObject		{

	NSMutableArray				*sessionHistory;
	NSString					*patientName;
	
	NSArray						*firstNamesArray;

	NSArray						*startMessagesArray;			//	these are generic messages to start the session
	NSArray						*genericRepliesArray;			//	these replies do not rely on input
	NSDictionary				*keywordRepliesDictionary;		//	if input contains a keyword, use the replies
	NSArray						*repliesArray;					//	these replies may use user input
	NSArray						*tooShortRepliesArray;				//	if the user inputs too little fallback on these
	NSArray						*shortRepliesArray;				//	if the user inputs too little fallback on these
	NSArray						*tooLongRepliesArray;			//	if the user inputs a phrase that is too long fallback on this

	int							maxInputBufferSize;
	int							maxRememberedLines;
	int							maxTokenSize;
	int							shortAnswerLength;
	int							veryShortAnswerLength;

	id							delegate;

}

- (void) generalInit;
- (void) loadProfileFromPath:(NSString *)p;
- (void) _loadNamesArray;

- (NSString *) patientName;

//	these methods create a response, push it to the session history, and return it
- (NSString *) startNewSession;
- (NSString *) makeGenericResponse;
- (NSString *) respondToString:(NSString *)input;

- (NSString *) _returnRandomOpening;
- (NSString *) _returnRandomGenericReply;
- (NSString *) _returnTooShortReply;
- (NSString *) _returnShortReply;
- (NSString *) _returnTooLongReply;
- (NSString *) _returnRandomReply;
- (NSString *) _detectNameInString:(NSString *)n;
- (NSString *) _returnReplyForKeywordsInPhrase:(NSString *)i;
- (NSString *) _fillStringTemplate:(NSString *)s withInputString:(NSString *)i;

- (NSArray *) sessionHistoryCopy;

@end
