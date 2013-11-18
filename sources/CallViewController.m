//
//  CallViewController.m
//  sdk-helper
//
//  Created by Charles Thierry on 7/19/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import "CallViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CallViewController ()

@end

@implementation CallViewController
@synthesize b_hangup;
@synthesize b_profile;
@synthesize b_toggleVideo;
@synthesize b_toggleAudio;
@synthesize b_rotate;
@synthesize call;
@synthesize v_videoIn;
@synthesize v_videoOut;


#pragma mark - Controller life cycle
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self setCall:[[Weemo instance] activeCall]];
		fillVideo = NO;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[self call]setDelegate:self];
	[[self call]setViewVideoIn:[self v_videoIn]];
	[[self call]setViewVideoOut:[self v_videoOut]];
	[[self b_rotate] setSelected:[[[Weemo instance] activeCall]followDeviceOrientation]];
	[self resizeView:[self interfaceOrientation]];

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)tO duration:(NSTimeInterval)duration
{
	[self resizeView:tO];
}


//updates the VideoViews location
- (void)resizeView:(UIInterfaceOrientation)tO
{
	[[self view]setFrame:CGRectMake(0., 0., [[[self view]superview]bounds].size.width, [[[self view]superview]bounds].size.height)];
	[self resizeVideoIn];
}

- (void)resizeVideoIn
{
	if ([[self call]getVideoInProfile].height <= 0 && [[self call]getVideoInProfile].width <= 0) return;
	float hRat = [[self call]getVideoInProfile].height / [[self view]bounds].size.height;
	float wRat = [[self call]getVideoInProfile].width / [[self view]bounds].size.width;
	if (fillVideo)
	{
		//we resize so that the biggest of the Rat is set to 1
		[[self v_videoIn]setFrame:CGRectMake(0., 0.,
											 [[self call] getVideoInProfile].width / ((hRat > wRat)?hRat:wRat),
											 [[self call] getVideoInProfile].height / ((hRat > wRat)?hRat:wRat))];
		[[self v_videoIn]setCenter:CGPointMake(self.view.bounds.size.width/2., self.view.bounds.size.height/2.)];
	} else {
		[[self v_videoIn]setFrame:CGRectMake(0., 0.,
											 [[self call] getVideoInProfile].width / ((hRat < wRat)?hRat:wRat),
											 [[self call] getVideoInProfile].height / ((hRat < wRat)?hRat:wRat))];
		[[self v_videoIn]setCenter:CGPointMake(self.view.bounds.size.width/2., self.view.bounds.size.height/2.)];
	}
}

#pragma mark - Actions

- (IBAction)hangup:(id)sender
{
	[[self call]hangup];
}

- (IBAction)profile:(id)sender
{
	[[self call] toggleVideoProfile];
}

- (IBAction)toggleVideo:(id)sender
{
	if ([[self call]isSendingVideo])
	{
		[[self call] videoStop];
	} else {
		[[self call] videoStart];
	}
}

- (IBAction)switchVideo:(id)sender
{
	[[self call] toggleVideoSource];
}

- (IBAction)toggleAudio:(id)sender
{
	if ([[self call]isSendingAudio])
	{
		[[self call] audioStop];
	} else {
		[[self call] audioStart];
	}
}

- (IBAction)rotate:(id)sender
{
//	[[[Weemo instance] activeCall]setFollowDeviceOrientation:![[[Weemo instance] activeCall]followDeviceOrientation]];
//	[[self b_rotate] setSelected:[[[Weemo instance] activeCall]followDeviceOrientation]];
}

#pragma mark - Call delegate

- (void)updateIdleStatus
{
	if ([[self call] isSendingVideo] || [[self call] isReceivingVideo])
	{
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	} else {
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
}

- (void)weemoCall:(id)sender videoReceiving:(BOOL)isReceiving
{
	NSLog(@">>>> CallViewController: Receiving: %@", isReceiving ? @"YES":@"NO");
	[self updateIdleStatus];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self v_videoIn]setHidden:!isReceiving];
		[self resizeVideoIn];
	});

}


- (void)weemoCall:(id)sender videoSending:(BOOL)isSending
{
	NSLog(@">>>> CallViewController: Sending: %@", isSending ? @"YES":@"NO");
	[self updateIdleStatus];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self b_toggleVideo]setSelected:isSending];
		[[self v_videoOut]setHidden:!isSending];
		[self resizeVideoIn];
	});
}



- (void)weemoCall:(id)sender videoProfile:(int)profile
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@">>>> CallViewController: videoProfile: %d", profile);
		[[self b_profile]setSelected:(profile != 0)];
		[self resizeVideoIn];
	});
}

- (void)weemoCall:(id)sender videoSource:(int)source
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@">>>> CallViewController: switchVideoSource: %@", (source == 0)?@"Front":@"Back");
		[[self b_switchVideo] setSelected:!(source == 0)];
		[self resizeVideoIn];
	});
}

- (void)weemoCall:(id)call audioSending:(BOOL)isSending
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@">>>> CallViewController: audioSending:%@", isSending?@"YES":@"NO");
		[[self b_toggleAudio]setSelected:!isSending];
	});
}

- (void)weemoCall:(id)sender callStatus:(int)status
{
	NSLog(@">>>> CallViewController: callStatus: 0x%X", status);
	[self updateIdleStatus];
	dispatch_async(dispatch_get_main_queue(), ^{
		if (status == CALLSTATUS_ACTIVE)
		{
			NSLog(@">>>> CallViewController: call went active");
		}
		if (status == CALLSTATUS_ENDED)
		{
			NSLog(@">>>> CallViewController: call was ended");
		}
	});
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touched = [touches anyObject];
	if ([touched view] == [self v_videoIn])
	{
		fillVideo = !fillVideo;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self resizeVideoIn];
		});
	}
}

@end
