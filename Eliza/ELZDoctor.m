#import "ELZDoctor.h"




@implementation ELZDoctor

- (id) init	{
	NSLog(@"%s",__func__);
	self = [super init];
	if (self!=nil)	{
		[self generalInit];
		return self;
	}
	return nil;
}

- (void) generalInit	{
	sessionHistory = [[NSMutableArray alloc] init];

	maxInputBufferSize = 180;
	maxRememberedLines = 30;
	maxTokenSize = 80;
	shortAnswerLength = 11;
	veryShortAnswerLength = 3;
	
	[self loadProfileFromPath:nil];
	[self _loadNamesArray];
	
	patientName = nil;
	
	srandomdev();
}

- (void) dealloc	{
	sessionHistory = nil;
	startMessagesArray = nil;
	genericRepliesArray = nil;
	keywordRepliesDictionary = nil;
	repliesArray = nil;
	tooShortRepliesArray = nil;
	shortRepliesArray = nil;
	tooLongRepliesArray = nil;
	patientName = nil;
	firstNamesArray = nil;
}

- (void) loadProfileFromPath:(NSString *)p	{
	//	if p is nil load a default plist from the package
	NSString			*profilePath = (p == nil) ? [[NSBundle mainBundle] pathForResource:@"English" ofType:@"plist" inDirectory:@"Languages"] : p;
	NSDictionary		*profileDict = [NSDictionary dictionaryWithContentsOfFile:profilePath];
	if (profileDict == nil)	{
		NSLog(@"err: failed loading %@",profilePath);
		return;
	}
	//NSLog(@"\t\tloaded from %@ - %@",profilePath,profileDict);
	startMessagesArray = [profileDict objectForKey:@"openings"];
	genericRepliesArray = [profileDict objectForKey:@"generic"];
	repliesArray = [profileDict objectForKey:@"responses"];
	shortRepliesArray = [profileDict objectForKey:@"short"];
	tooShortRepliesArray = [profileDict objectForKey:@"tooshort"];
	tooLongRepliesArray = [profileDict objectForKey:@"toolong"];
	keywordRepliesDictionary = [profileDict objectForKey:@"keywords"];
}

- (void) _loadNamesArray	{
	NSString			*allNamesTextPath = [[NSBundle mainBundle] pathForResource:@"first-names" ofType:@"txt"];
	if (allNamesTextPath == nil)
		return;
	NSStringEncoding	tmpEncoding;
	NSString			*allNamesText = [NSString stringWithContentsOfFile:allNamesTextPath usedEncoding:&tmpEncoding error:nil];
	if (allNamesText == nil)
		return;
	
	firstNamesArray = [allNamesText componentsSeparatedByString:@" "];
	//NSLog(@"\t\tfound names %@",firstNamesArray);
	//NSLog(@"\t\tloaded %ld names",[firstNamesArray count]);
}

//	each of these return the string that they pushed to the session history
- (NSString *) startNewSession	{
	NSLog(@"%s",__func__);
	[sessionHistory removeAllObjects];
	patientName = nil;
	NSString		*returnMe = [self _returnRandomOpening];
	if (returnMe != nil)	{
		NSDictionary	*entryDict = [NSDictionary dictionaryWithObjectsAndKeys:returnMe,kELZDoctorResponseString,nil];
		[sessionHistory addObject:entryDict];
	}
	return returnMe;
}

- (NSString *) makeGenericResponse	{
	NSLog(@"%s",__func__);
	NSString		*returnMe = [self _returnRandomGenericReply];
	if (returnMe != nil)	{
		NSDictionary	*entryDict = [NSDictionary dictionaryWithObjectsAndKeys:returnMe,kELZDoctorResponseString,nil];
		[sessionHistory addObject:entryDict];
	}
	return returnMe;
}

- (NSString *) respondToString:(NSString *)input	{
	//NSLog(@"%s",__func__);
	if ((input == nil)||([input length] == 0))
		return nil;
	
	NSString		*replyStringTemplate = nil;
	NSString		*keywordPhrase = [self _returnReplyForKeywordsInPhrase:input];
	
	//	Get a template for the reply
	
	if ([sessionHistory count] == 1)	{
		patientName = [self _detectNameInString:input];
		replyStringTemplate = [self _returnRandomGenericReply];
		if (patientName != nil)	{
			NSLog(@"\t\tnow talking to %@",patientName);
		}
	}
	else if ([sessionHistory count] < 2)	{
		replyStringTemplate = [self _returnRandomGenericReply];
	}
	else if (keywordPhrase != nil)	{
		replyStringTemplate = keywordPhrase;
	}
	else if ([input length] <= veryShortAnswerLength)	{
		//	Respond with very short reply
		replyStringTemplate = [self _returnTooShortReply];
	}
	else if ([input length] <= shortAnswerLength)	{
		//	Respond with very short reply
		replyStringTemplate = [self _returnShortReply];
	}
	else if ([input length] > maxInputBufferSize)	{
		//	Respond with too long reply
		replyStringTemplate = [self _returnTooLongReply];
	}
	else	{
		//	Get a random reply template
		replyStringTemplate = [self _returnRandomReply];
	}

	//	Do any replacing on the reply string as needed from history
	NSString		*returnMe = [self _fillStringTemplate:replyStringTemplate withInputString:input];
	
	//	Create the new history entry dict and return
	if (returnMe != nil)	{
		NSDictionary	*entryDict = [NSDictionary dictionaryWithObjectsAndKeys:input,kELZPatientInputString,returnMe,kELZDoctorResponseString,nil];
		[sessionHistory addObject:entryDict];
	}
	return returnMe;
}

- (NSString *) _returnRandomOpening	{
	NSString		*returnMe = nil;
	if (startMessagesArray == nil)	{
		returnMe = @"Hello, how are you today?";
	}
	else	{
		NSUInteger			stringsCount = [startMessagesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [startMessagesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hello, how are you today?";
		}
	}
	return returnMe;
}

- (NSString *) _returnRandomGenericReply	{
	NSString		*returnMe = nil;
	if (genericRepliesArray == nil)	{
		returnMe = @"Hmmm.";
	}
	else	{
		NSUInteger			stringsCount = [genericRepliesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [genericRepliesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hmmmm.";
		}
	}
	return returnMe;
}

- (NSString *) _returnTooShortReply	{
	NSString		*returnMe = nil;
	if (tooShortRepliesArray == nil)	{
		returnMe = @"Hmmm.";
	}
	else	{
		NSUInteger			stringsCount = [tooShortRepliesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [tooShortRepliesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hmmmm.";
		}
	}
	return returnMe;
}

- (NSString *) _returnShortReply	{
	NSString		*returnMe = nil;
	if (shortRepliesArray == nil)	{
		returnMe = @"Hmmm.";
	}
	else	{
		NSUInteger			stringsCount = [shortRepliesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [shortRepliesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hmmmm.";
		}
	}
	return returnMe;
}

- (NSString *) _returnTooLongReply	{
	NSString		*returnMe = nil;
	if (tooLongRepliesArray == nil)	{
		returnMe = @"Hmmm.";
	}
	else	{
		NSUInteger			stringsCount = [tooLongRepliesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [tooLongRepliesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hmmmm.";
		}
	}
	return returnMe;
}

- (NSString *) _returnRandomReply	{
	NSString		*returnMe = nil;
	if (repliesArray == nil)	{
		returnMe = @"Hmmm.";
	}
	else	{
		NSUInteger			stringsCount = [repliesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [repliesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hmmmm.";
		}
	}
	return returnMe;
}

- (NSString *) _returnRandomPatientString	{
	NSString		*returnMe = nil;
	if (sessionHistory != nil)	{
		NSUInteger			stringsCount = [sessionHistory count];
		if (stringsCount > 2)	{
			double		rand = round((stringsCount - 3) * ((double)random()/(RAND_MAX)));
			if (rand < 2)
				rand = 2;
			NSDictionary	*tmpDict = [sessionHistory objectAtIndex:rand];
			returnMe = [tmpDict objectForKey:kELZPatientInputString];
		}
	}
	return returnMe;
}

- (NSString *) _detectNameInString:(NSString *)n	{
	if ((n == nil)||([n length] == 0))
		return nil;

	NSString		*returnMe = nil;
	NSArray			*wordsArray = [n componentsSeparatedByString:@" "];
	if ([wordsArray count] == 1)	{
		returnMe = n;
	}
	/*
	else if ([wordsArray count] == 2)	{
		returnMe = n;
	}
	*/
	//	if it isn't a one word answer go through our list of 'all' names
	else if (firstNamesArray != nil)	{
		for (NSString *name in firstNamesArray)	{
			for (NSString *word in wordsArray)	{
				if ([name caseInsensitiveCompare:word] ==  NSOrderedSame)	{
					returnMe = name;
					NSLog(@"\t\tfound name '%@'",returnMe);
					break;
				}
			}
			if (returnMe != nil)	{
				break;
			}
			/*
			NSString	*tmpName = [name stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			NSRange		stringRange = [n rangeOfString:tmpName options:NSCaseInsensitiveSearch];
			if (stringRange.location != NSNotFound)	{
				NSLog(@"\t\tfound '%@'",name);
				returnMe = name;
				break;
			}
			else	{
				//NSLog(@"\t\tname is not '%@' in %@",tmpName,n);
			}
			*/
		}
	}
	
	return returnMe;
}

- (NSString *) _returnReplyForKeywordsInPhrase:(NSString *)i	{
	if (i == nil)
		return nil;
	if (keywordRepliesDictionary == nil)
		return nil;
	NSString			*returnMe = nil;
	NSArray				*keywordsArray = [keywordRepliesDictionary allKeys];
	NSMutableArray		*localRepliesArray = [NSMutableArray arrayWithCapacity:0];
	
	for (NSString *keyword in keywordsArray)	{
		NSRange		stringRange = [i rangeOfString:keyword options:NSCaseInsensitiveSearch];
		if (stringRange.location != NSNotFound)	{
			//NSLog(@"\t\tdetected keyword %@",keyword);
			NSArray		*tmpArray = [keywordRepliesDictionary objectForKey:keyword];
			[localRepliesArray addObjectsFromArray:tmpArray];
		}
	}
	
	if ([localRepliesArray count] > 0)	{
		NSUInteger			stringsCount = [localRepliesArray count];
		if (stringsCount > 0)	{
			double		rand = round((stringsCount - 1) * ((double)random()/(RAND_MAX)));
			returnMe = [localRepliesArray objectAtIndex:rand];
		}
		else	{
			returnMe = @"Hm?";
		}
	}
	
	return returnMe;
}

- (NSString *) _fillStringTemplate:(NSString *)s withInputString:(NSString *)i	{
	if (s == nil)
		return nil;
	NSString		*returnMe = s;
	
	if (i != nil)
		returnMe = [returnMe stringByReplacingOccurrencesOfString:@"--INPUT--" withString:i];
	
	if (patientName != nil)
		returnMe = [returnMe stringByReplacingOccurrencesOfString:@"--NAME--" withString:patientName];
	else
		returnMe = [returnMe stringByReplacingOccurrencesOfString:@"--NAME--" withString:@"patient"];
	
	//	grab a history string; if one doesn't exist yet use the input string passed in
	NSString		*randomHistoryString = [self _returnRandomPatientString];
	if (randomHistoryString != nil)
		returnMe = [returnMe stringByReplacingOccurrencesOfString:@"--OLDINPUT--" withString:randomHistoryString];
	else if (i != nil)
		returnMe = [returnMe stringByReplacingOccurrencesOfString:@"--OLDINPUT--" withString:i];
	
	return returnMe;
}

- (NSString *) patientName	{
	if (patientName != nil)
		return [patientName copy];
	else
		return @"Patient";
}

- (NSArray *) sessionHistoryCopy	{
	return [NSArray arrayWithArray:sessionHistory];
}

@end
