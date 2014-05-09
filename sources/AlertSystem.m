#import "AlertSystem.h"

static AlertSystem* sharedAlert = nil;

@interface AlertSystem ()
{
	NSString *selectedRingtone;
	NSString *proceedingRingtone;
	
	NSTimer *viTimer;
	NSTimer *riTimer;
	SystemSoundID ring;
	SystemSoundID proceed;
}

@property (nonatomic) UILocalNotification *ln_callincoming;

@end


@implementation AlertSystem

+ (void)initialize
{
	[AlertSystem sharedAlert];
}

- (id)init
{
	self = [super init];
	if (self) {
		selectedRingtone = @"ringing";
		proceedingRingtone = @"ringback";
		
	}
	return self;
}

+ (AlertSystem *)sharedAlert
{
    static dispatch_once_t centralControllerToken;
	
    dispatch_once(&centralControllerToken, ^{
        sharedAlert = [[AlertSystem alloc] init];
    });
    return sharedAlert;
}

- (void)startProceeding
{
	//synchronized because we don't want multiple sound fired at the same time.
	@synchronized([AlertSystem class])
	{
		[self stopRinging];
		NSString *soundPath = [[NSBundle mainBundle] pathForResource:proceedingRingtone ofType:@"aiff"];
		NSURL *url = nil;
		if (soundPath != nil)
			url = [NSURL fileURLWithPath:soundPath];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url) , &proceed);
		riTimer = [NSTimer timerWithTimeInterval:4.
										  target:self
										selector:@selector(proceed:)
										userInfo:nil repeats:YES];
		
		[[NSRunLoop mainRunLoop] addTimer:riTimer forMode:NSRunLoopCommonModes];
		[riTimer fire];
	}
}

- (void)startRinging
{
	//synchronized because we don't want multiple sound fired at the same time.
	@synchronized([AlertSystem class])
	{
		[self stopRinging];

		NSString *soundPath = [[NSBundle mainBundle] pathForResource:selectedRingtone ofType:@"aiff"];
		NSURL *url = nil;
		if (soundPath != nil)
			url = [NSURL fileURLWithPath:soundPath];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url) , &ring);

		if (riTimer != nil)
		{
			[riTimer invalidate];
			riTimer = nil;
		}
		
		riTimer = [NSTimer timerWithTimeInterval:4.
												   target:self
												 selector:@selector(ring:)
												userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:riTimer forMode:NSRunLoopCommonModes];
		[riTimer performSelectorInBackground:@selector(fire) withObject:nil];
	};

}


- (void)vib:(NSTimer*)ti
{
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (void)proceed:(NSTimer*)ti
{
	AudioServicesPlaySystemSound(proceed);
}

- (void)ring:(NSTimer*)ti
{
	AudioServicesPlaySystemSound(ring);
}

- (void)stopRinging
{
	AudioServicesDisposeSystemSoundID(proceed);
	AudioServicesDisposeSystemSoundID(ring);
	[riTimer invalidate];
	riTimer = nil;
}

- (BOOL)displayLocalNotification:(NSString *)contactDisplayName
{
	BOOL wasCreated = ([self ln_callincoming] == nil);
	if ([self ln_callincoming] == nil)
	{
		[self setLn_callincoming: [[UILocalNotification alloc] init]];

	}
	NSDictionary *userInfo =[NSDictionary dictionaryWithObjectsAndKeys:@"call",@"alertType", nil];
	[self ln_callincoming].alertBody = [NSString stringWithFormat:@"Incoming Call From: %@", contactDisplayName];
	[self ln_callincoming].userInfo = userInfo;
	[self ln_callincoming].alertAction = NSLocalizedString(@"NotifCall", nil);
	[self ln_callincoming].soundName = selectedRingtone;
	[[UIApplication sharedApplication] presentLocalNotificationNow:[self ln_callincoming]];
	return wasCreated;
}

- (void)dismissLocalNotification
{
	if ([self ln_callincoming])
		[[UIApplication sharedApplication] cancelLocalNotification:[self ln_callincoming]];
	[self setLn_callincoming:nil];
}


@end
