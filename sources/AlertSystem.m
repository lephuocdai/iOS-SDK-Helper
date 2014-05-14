#import "AlertSystem.h"
#import <QuartzCore/QuartzCore.h>

static AlertSystem* sharedAlert = nil;

@interface AlertSystem ()
{
	NSString *selectedRingtone;
	NSString *proceedingRingtone;
	
	NSTimer *viTimer;
	NSTimer *riTimer;
	SystemSoundID ring;
	SystemSoundID proceed;
	
	UILabel *displayView;
	float animTimer;
	NSTimer *displayTimer;
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

- (void)displayMessage:(NSString *)message during:(float)timer inView:(UIView *)target animated:(BOOL)a
{
	if (!displayView)
	{
		displayView = [[UILabel alloc] init];
		[displayView setTextAlignment:NSTextAlignmentCenter];
		[displayView setTextColor:[UIColor colorWithWhite:1. alpha:1.]];

		[[displayView layer] setBackgroundColor:[UIColor colorWithWhite:0. alpha:.6].CGColor];
		[displayView setBackgroundColor:[UIColor colorWithWhite:0. alpha:0.]];
	}
	animTimer = a?timer:0.;
	[displayTimer invalidate];
	
	dispatch_async(dispatch_get_main_queue() ,^{
		[UIView animateWithDuration:animTimer animations:^{
			[displayView setAlpha:0.];
		} completion:^(BOOL finished) {
			[displayView setText:message];
			[displayView sizeToFit];
			CGRect textBounds= [displayView bounds];
			textBounds.size.width += 30.;
			textBounds.size.height += 30.;
			[displayView setFrame:textBounds];
			[displayView setCenter:CGPointMake([target bounds].size.width/2., [target bounds].size.height/2.)];
			[self displayViewUpdate];
			[target addSubview:displayView];

			[UIView animateWithDuration:animTimer animations:^{
				[displayView setAlpha:1.];
			}completion:^(BOOL finished) {
				displayTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self
															  selector:@selector(dismissDisplayView:)
															  userInfo:nil repeats:NO];
			}];
		}];
	});
}

- (void)dismissDisplayView:(NSTimer *)t
{
	dispatch_async(dispatch_get_main_queue() ,^{
		[UIView animateWithDuration:animTimer animations:^{
			[displayView setAlpha:0.];
			[displayView removeFromSuperview];
			displayView = nil;
		}];
	});
}

- (void)displayViewUpdate
{
	[[displayView layer] setCornerRadius:10.];
	[[displayView layer] setShouldRasterize:YES];
}



@end
