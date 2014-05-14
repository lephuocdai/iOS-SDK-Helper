//
//  CallViewController.m
//  sdk-helper
//
//  Created by Charles Thierry on 7/19/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import "CallViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AlertSystem.h"
#import "HomeViewController.h"

#import <QuartzCore/QuartzCore.h>

#define MAXDIM_MONITOR 120.

@interface CallViewController ()

@end

@implementation CallViewController
{
	NSTimer *callMenuHide;
}
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

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	UITapGestureRecognizer *doubletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubletap:) ];
	[doubletap setNumberOfTapsRequired:2];
	[doubletap setCancelsTouchesInView:NO];
	[[self v_videoIn] addGestureRecognizer:doubletap];

}

- (void)viewWillAppear:(BOOL)animated
{
	
	[super viewWillAppear:animated];
	[[self call] setDelegate:self];
	[[self call] setViewVideoIn:[self v_videoIn]];
	[[self call] setViewVideoOut:[self v_videoOut]];
	[[[self b_hangup] layer] setCornerRadius: [[self b_hangup] frame].size.width/2.];
	[[[self b_profile] layer] setCornerRadius: [[self b_profile] frame].size.width/2.];
	[[[self b_switchVideo] layer] setCornerRadius: [[self b_switchVideo] frame].size.width/2.];
	[[[self b_toggleAudio] layer] setCornerRadius: [[self b_toggleAudio] frame].size.width/2.];
	[[[self b_toggleVideo] layer] setCornerRadius: [[self b_toggleVideo] frame].size.width/2.];
	
	[[[self b_hangup] layer] setBorderColor:[UIColor colorWithWhite:0. alpha:.35].CGColor];
	[[[self b_profile] layer] setBorderColor:[UIColor colorWithWhite:0. alpha:.35].CGColor];
	[[[self b_switchVideo] layer] setBorderColor:[UIColor colorWithWhite:0. alpha:.35].CGColor];
	[[[self b_toggleAudio] layer] setBorderColor:[UIColor colorWithWhite:0. alpha:.35].CGColor];
	[[[self b_toggleVideo] layer] setBorderColor:[UIColor colorWithWhite:0. alpha:.35].CGColor];
	
	[[[self b_hangup] layer] setBorderWidth:1.];
	[[[self b_profile] layer] setBorderWidth:1.];
	[[[self b_switchVideo] layer] setBorderWidth:1.];
	[[[self b_toggleAudio] layer] setBorderWidth:1.];
	[[[self b_toggleVideo] layer] setBorderWidth:1.];
	[self resizeView:[self interfaceOrientation]];

	[[self b_hangup] setSelected:NO];
	[[self b_profile] setSelected:NO];
	[[self b_switchVideo] setSelected:NO];
	[[self b_toggleAudio] setSelected:NO];
	[[self b_toggleVideo] setSelected:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self resetHideTimer];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)tO duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:tO duration:duration];
	[self resizeView:tO];
}


- (void)resizeView:(UIInterfaceOrientation)tO
{

	[self resizeVideoIn:NO];
}

- (void)fillScreen:(CGSize)s
{
	
	float width = [[self call] getVideoInProfile].width / ( (s.height > s.width)?s.height:s.width );
	float height = [[self call] getVideoInProfile].height / ( (s.height > s.width)?s.height:s.width );
	[[self v_videoIn]setFrame:CGRectMake(self.view.bounds.size.width/2. - width/2., self.view.bounds.size.height/2. - height/2.,
										 width, height)];
}

- (void)fitScreen:(CGSize)s
{
	float width = [[self call] getVideoInProfile].width / ((s.height < s.width)?s.height:s.width);
	float height = [[self call] getVideoInProfile].height / ((s.height < s.width)?s.height:s.width);
	[[self v_videoIn]setFrame:CGRectMake(self.view.bounds.size.width/2. - width/2., self.view.bounds.size.height/2. - height/2.,
										 width,height)];
}


- (void)resizeVideoIn:(BOOL)animated
{
	if ([[self call]getVideoInProfile].height <= 0 && [[self call]getVideoInProfile].width <= 0) return;
	float hRat = [[self call]getVideoInProfile].height / [[self view]bounds].size.height;
	float wRat = [[self call]getVideoInProfile].width / [[self view]bounds].size.width;
	if (fillVideo)
	{
		//we resize so that the max(hRat, wRat) is set to 1
		if (animated)
		{
			[UIView animateWithDuration:.1 animations:^{
				[self fillScreen:CGSizeMake(wRat, hRat)];
			}];
			
		} else {
			[self fillScreen:CGSizeMake(wRat, hRat)];
		}
		
	} else {
		if (animated)
		{
			[UIView animateWithDuration:.1 animations:^{
				[self fitScreen:CGSizeMake(wRat, hRat)];
			}];
		} else {
			[self fitScreen:CGSizeMake(wRat, hRat)];
		}
	}
}

#pragma mark - Actions

- (IBAction)hangup:(id)sender
{
	[self releaseButton:sender];
	[[self call]hangup];
}

- (IBAction)profile:(id)sender
{
	[self releaseButton:sender];
	[[self call] toggleVideoProfile];
}

- (IBAction)toggleVideo:(id)sender
{
	[self releaseButton:sender];
	if ([[self call] isSendingVideo])
	{
		[[self call] videoStop];
	} else {
		[[self call] videoStart];
	}
}

- (IBAction)switchVideo:(id)sender
{
	[self releaseButton:sender];
	[[self call] toggleVideoSource];
}

- (IBAction)toggleAudio:(id)sender
{
	[self releaseButton:sender];
	if ([[self call]isSendingAudio])
	{
		[[self call] audioStop];
	} else {
		[[self call] audioStart];
	}
}

- (IBAction)pressButton:(id)sender
{
	[sender setBackgroundColor:[UIColor colorWithWhite:1. alpha:.50]];
}

- (IBAction)releaseButton:(id)sender
{
	[UIView animateWithDuration:.3 animations:^{
		[sender setBackgroundColor:[UIColor colorWithWhite:1. alpha:.0]];
	}];
}

- (void)doubletap:(UITapGestureRecognizer*)dbt
{
	if ([dbt state] == UIGestureRecognizerStateRecognized)
	{
		fillVideo = !fillVideo;
		[self resizeVideoIn:YES];
		[self resetHideTimer];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
		[[self v_callMenu] setAlpha:1.];
	});
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self resetHideTimer];
	});
}

#pragma mark - Call Menu 



- (void)resetHideTimer
{
	[callMenuHide invalidate];
	callMenuHide = [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(hideTheMenu:) userInfo:nil repeats:NO];
}

- (void)hideTheMenu:(NSTimer *)timer
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[UIView animateWithDuration:.3 animations:^{
			if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
			{//hide the status bar only if iOS 7.+
				[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
			}

			[[self v_callMenu] setAlpha:0.];
		}];
	});
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

- (void)weemoCall:(id)sender videoOutSizeChange:(CGSize)size
{
	NSLog(@">>> %s %@ (%@)", __FUNCTION__, CGSizeCreateDictionaryRepresentation(size), [self v_videoOut]);
	float max = fmaxf(size.width, size.height);
	if (max != 0)
	{
		float fw = MAXDIM_MONITOR * size.width / max;
		float fh = MAXDIM_MONITOR * size.height / max;
		NSLog(@">>> %s vidOut %f*%f", __FUNCTION__, fw, fh);
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self v_videoOut] setFrame:CGRectMake(0., [[self view] bounds].size.height - fh, fw, fh)];
		});
	}
}

- (void)weemoCall:(id)sender videoReceiving:(BOOL)isReceiving
{
//	NSLog(@">>>> %s %@",__FUNCTION__, isReceiving ? @"YES":@"NO");
	[self updateIdleStatus];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self v_videoIn] setHidden:!isReceiving];
		[self resizeVideoIn:NO];
	});
	
}

- (void)weemoCall:(id)sender videoSending:(BOOL)isSending
{
//	NSLog(@">>>> %s %@", __FUNCTION__, isSending ? @"YES":@"NO");
	[self updateIdleStatus];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self b_toggleVideo] setSelected:isSending];
		[[self v_videoOut] setHidden:!isSending];
		[self resizeVideoIn:NO];
	});
}

- (void)weemoCall:(id)sender videoProfile:(int)profile
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@">>>> %s %d", __FUNCTION__, profile);
		[[self b_profile] setSelected:(profile != 0)];
		[self resizeVideoIn:NO];
	});
}

- (void)weemoCall:(id)sender videoSource:(int)source
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@">>>> %s %@", __FUNCTION__, (source == 0)?@"Front":@"Back");
		[[self b_switchVideo] setSelected:!(source == 0)];
		[self resizeVideoIn:NO];
	});
}

- (void)weemoCall:(id)call audioSending:(BOOL)isSending
{
	dispatch_async(dispatch_get_main_queue(), ^{
		NSLog(@">>>> %s %@", __FUNCTION__, isSending?@"YES":@"NO");
		[[self b_toggleAudio] setSelected:!isSending];
	});
}

- (void)weemoCall:(id)sender callStatus:(int)status
{
	NSLog(@">>>> %s 0x%X", __FUNCTION__, status);
	[self updateIdleStatus];
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (status) {
			case CALLSTATUS_ACTIVE:
				NSLog(@">>>> CallViewController: call went active");
				[[AlertSystem sharedAlert] stopRinging];
				[[AlertSystem sharedAlert] dismissLocalNotification];
				[(HomeViewController *)[self parentViewController] callBecameActive];
				break;
			case CALLSTATUS_ENDED:
				NSLog(@">>>> CallViewController: call was ended");
				[[AlertSystem sharedAlert] stopRinging];
				[[AlertSystem sharedAlert] dismissLocalNotification];
				break;
			default:
				break;
		}
	});
}


@end
