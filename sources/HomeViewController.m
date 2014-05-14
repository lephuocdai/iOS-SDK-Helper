//
//  SchemeControllerViewController.m
//  sdk-helper
//
//  Created by Charles Thierry on 9/24/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "AlertSystem.h"
#import <objc/message.h>
#import <CrashReporter/CrashReporter.h>

#import "zipFile.h"


@interface HomeViewController ()
@property (nonatomic) UIAlertView *incoming;
@property (nonatomic) UIAlertView *emitting;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[DataGroup instance] setLoginDelegate:self];
	[[DataGroup instance] setContactDelegate:self];
	
	[[self tf_mobileappid]setText:[[DataGroup instance] URLRef]];
	[[self tf_UID] setText:[[DataGroup instance] token]];
	[[self tf_displayname] setText:[[DataGroup instance] displayname]];
	
}


- (IBAction)appSite:(id)sender
{
	//send the log
	if (![Weemo instance])
	{
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Sorry"
														  message:@"The weemo singleton must have been initialized before you can send logs."
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		[message show];
		return;
	}
	if ([[Weemo instance] respondsToSelector:@selector(createLogfile)])
	{
		SEL selec = NSSelectorFromString(@"createLogfile");
		// This is to override the default HAP behaviour only if the AppDelegate has a launchParameters method declared
		id bic = objc_msgSend([Weemo instance], selec);
		if (![bic isKindOfClass:[NSString class]])
		{
			NSLog(@"Returned type invalid.");
			return;
		}
		if ([bic isEqualToString:@""])
		{
			NSLog(@"No log file available");
			return;
		}
		//NSString *bic is the logFile URI
		if (![MFMailComposeViewController canSendMail]) {
			UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Mail"
															  message:@"No e-mail account configured on this device"
															 delegate:nil
													cancelButtonTitle:@"Cancel"
													otherButtonTitles:nil];
			[message show];
			return;
		}

		[[self b_logo] setEnabled:NO];
		[self performSelectorInBackground:@selector(prepareMail:) withObject:bic];
		
	}
	[[self view] endEditing:YES];
}

- (IBAction)connect:(UIButton *)sender
{
	[self releaseButton:sender withGlow:YES];
	[[self view]endEditing:YES];
	if ([[DataGroup instance] status] == sta_notConnected)
	{
		NSLog(@">>> Pressing connect");
		NSDictionary *parameters =[NSDictionary dictionaryWithObjectsAndKeys:[[self tf_UID] text], KEY_TOKEN,
								   [[[self tf_displayname] text] isEqualToString:@""]?[[self tf_UID] text]:[[self tf_displayname] text], KEY_DISPLA,
								   [[[self tf_mobileappid] text] isEqualToString:@""]?DEFAULTKEY: [[self tf_mobileappid] text], KEY_MOBILEAPPID,
								   nil];
		[self dgStatusChange:sta_connected];
		[[DataGroup instance] initiateWithParameters:parameters];

	} else if ([[DataGroup instance] status] == sta_authenticated)
	{
		NSLog(@">>> Pressing disconnect");
		[[DataGroup instance] doDisconnect];
	}	
}

- (IBAction)call:(id)sender
{
	[self releaseButton:sender withGlow:YES];
	NSLog(@">>> Pressing call");
	[[self view]endEditing:YES];
	[[AlertSystem sharedAlert] startProceeding];
	[[DataGroup instance] call:[[self tf_contactid] text]];
}

- (IBAction)checkUser:(id)sender
{
	[self releaseButton:sender withGlow:YES];
	[[self view]endEditing:YES];
	[[DataGroup instance] checkAvailable:[[self tf_contactid] text]];
}

- (IBAction)pressButton:(id)sender
{
	[sender setBackgroundColor:[UIColor colorWithWhite:.21 alpha:.11]];
}

- (void)releaseButton:(id)sender withGlow:(BOOL)glow
{
	[UIView animateWithDuration:.03 animations:^{
		[sender setBackgroundColor:[UIColor colorWithWhite:1. alpha:.51]];
	} completion:^(BOOL finished) {
		[self releaseButton:sender];
	}];
	
}

- (IBAction)releaseButton:(id)sender
{
	[UIView animateWithDuration:.3 animations:^{
		[sender setBackgroundColor:[UIColor colorWithWhite:1. alpha:.11]];
	}];
}


#pragma mark - textField delegation
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[[self view]endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[[self view]endEditing:YES];
	return YES;
}

- (void)createCallView
{
	NSLog(@">>>> createCallView");
	if (![self cvc_active]) {
		_cvc_active = [[self storyboard] instantiateViewControllerWithIdentifier:@"CallViewController"];
	}
	
	[[[Weemo instance] activeCall] setDelegate:[self cvc_active]];
	[self addChildViewController:[self cvc_active]];
}

- (void)addCallView
{
	NSLog(@">>>> addCallView ");
	if (![self cvc_active]) [self createCallView];
	[[self cvc_active] removeFromParentViewController];
	[self presentViewController:[self cvc_active] animated:YES completion:nil];

}

- (void)removeCallView
{
//	[[self cvc_active] removeFromParentViewController];
//	[[[self cvc_active] view]removeFromSuperview];
	[self dismissViewControllerAnimated:YES completion:nil];
	_cvc_active = nil;
}

#pragma mark -

- (void)callBecameActive
{
	[self addCallView];
	[[self emitting] dismissWithClickedButtonIndex:-1 animated:NO];
	[[self incoming] dismissWithClickedButtonIndex:-1 animated:NO];
	[self setEmitting: nil]; [self setIncoming: nil];
	[[AlertSystem sharedAlert] stopRinging];
	[[AlertSystem sharedAlert] dismissLocalNotification];
}



#pragma mark - mail view for sending logs
- (void)prepareMail:(NSString *)logFile
{
	MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
	[composer setMailComposeDelegate:self];
	[composer setToRecipients:[NSArray arrayWithObject:mailRecipients]];
	
	//zip the logfile
	NSString *destinationPath = [logFile stringByAppendingString:@".gzip"];
	FILE *source = fopen([logFile UTF8String], "rb");
	FILE *destination = fopen([destinationPath UTF8String], "wb");
	zipFile(source, destination);
	fclose(source);
	fclose(destination);
	
	//add the file to the mail
	[composer addAttachmentData:[NSData dataWithContentsOfFile:destinationPath]
					   mimeType:@"application/gzip" fileName:[destinationPath lastPathComponent]];

	//will be filled to indicate the nature of the log
	NSString *reportNature = @"";
	
	//search if any crashfile was generated by the crash library
	PLCrashReporter *rep = [PLCrashReporter sharedReporter];
	if ([rep hasPendingCrashReport])
	{
		NSString *crashFile = nil;
		crashFile = [NSString stringWithFormat:@"%@.crash", logFile];
		NSString *crashtextContent = [PLCrashReportTextFormatter stringValueForCrashReport:[[PLCrashReport alloc]initWithData:[rep loadPendingCrashReportData] error:nil]
																			  withTextFormat:PLCrashReportTextFormatiOS];
		//create a file containing the crash info
		[[NSFileManager defaultManager] createFileAtPath:crashFile
												contents:[crashtextContent dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
		//remove the crash info stored by the crash library
		[rep purgePendingCrashReport];
		//add the crash file to the mail
		[composer addAttachmentData: [NSData dataWithContentsOfFile:crashFile]
						   mimeType:@"text/plain" fileName:[crashFile lastPathComponent]];
		
		reportNature = @"Crash";
	} else {
		reportNature = @"Report";
	}
	
	[composer setSubject:[NSString stringWithFormat:mailSubject, [Weemo getVersion], reportNature, platformType()]];
	
	NSString *message = [NSString stringWithFormat:@"%@ %@\n\n"
						 "PF (Prod, Pre-prod, …):\n\n"
						 "Provider name: %@\n\n"
						 "Caller_UID: %@\n"
						 "Caller_type (WD, SDK, WRTC):\n\n"
						 "Callee_UID:\n"
						 "Callee_type (WD, SDK, WRTC):\n\n"
						 "Issue (crash, call stopped, call not started, no audio, no video,…):\n\n"
						 "Scenario (back ground, screen locked, network change, sleep, rotation, incoming gsm call, …):\n\n"
						 "Frequency (%%):\n\n"
						 "Audio Quality (1 – 10): -> Optional\n\n"
						 "Video Quality (1 – 10): -> Optional\n\n"
						 "Network variable (wifi vs 4G Vz vs 4G ATT vs …): —> Optional\n\n"
						 "Device variable (Tom C vs Tom S iphone, …): —> Optional\n\n",  [Weemo getVersion], platformType(),
						 [[DataGroup instance] URLRef],
						 [[DataGroup instance] token] ];
	
	

	[composer setMessageBody:message isHTML:NO];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self presentComposer:composer];
	});
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self b_logo] setEnabled:YES];
		[self dismissViewControllerAnimated:YES completion:nil];
	});
}

- (void)presentComposer:(MFMailComposeViewController*)composer
{
	[self presentViewController:composer animated:YES completion:^{
		[[self b_logo] setEnabled:YES];
	}];

}


#pragma mark - Alertviews.

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == _emitting)
	{
		[self removeCallView];
		[[[Weemo instance] activeCall] hangup];
	} else if (alertView == _incoming)
	{
		if (buttonIndex == 0)
		{
			[self createCallView];
			[self addCallView];
			[[[Weemo instance] activeCall]resume];
		} else {
			//user hangup
			[self removeCallView];
			if (buttonIndex > 0)
				[[[Weemo instance] activeCall]hangup];
		}
	}
}

#pragma mark - LoginProtocol delegation

- (void)dgContact:(NSString *)contactUID canBeCalled:(BOOL)canBe
{
	[[AlertSystem sharedAlert] displayMessage:[NSString stringWithFormat:@"%@ can %@be called",contactUID, canBe?@"":@"not "] during:1. inView:[self view] animated:YES];
}

- (void)dgCallStatusChange:(WeemoCall *)call
{
	if ([call callStatus] == CALLSTATUS_RINGING)
	{
		[self setIncoming: [[UIAlertView alloc]initWithTitle:ALERT_INCO
													 message:[NSString stringWithFormat:@"%@ is calling", [call contactID]]
													delegate:self
										   cancelButtonTitle:@"Pick-up"
										   otherButtonTitles:@"Deny", nil]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@">>> HomeViewController CALLSTATUS_RINGING");
			[[self incoming] show];
			[[AlertSystem sharedAlert] displayLocalNotification:[call contactID]];
			[[AlertSystem sharedAlert] startRinging];
		});
		
	} else if ([call callStatus] == CALLSTATUS_ENDED || call == nil) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@">>> HomeViewController CALLSTATUS_ENDED");
			[[self emitting] dismissWithClickedButtonIndex:-1 animated:YES];
			[[self incoming] dismissWithClickedButtonIndex:-1 animated:YES];
			[self setEmitting: nil]; [self setIncoming: nil];
			[[AlertSystem sharedAlert] stopRinging];
			[[AlertSystem sharedAlert] dismissLocalNotification];
			[self removeCallView];
			[[self tf_contactid]setText:@""];
		});
	} else if ([call callStatus] == CALLSTATUS_PROCEEDING)
	{
		[self setEmitting:[[UIAlertView alloc]initWithTitle:ALERT_EMIT
													message:[NSString stringWithFormat:@"You are calling %@", [call contactID]]
												   delegate:self
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:nil]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@">>> HomeViewController CALLSTATUS_PROCEEDING");
			[[AlertSystem sharedAlert] startProceeding];
			[self createCallView];
			[[self emitting] show];
		});
	} else if ([call callStatus] == CALLSTATUS_ACTIVE)
	{
		NSLog(@">>> HomeViewController CALLSTATUS_ACTIVE");
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self emitting] dismissWithClickedButtonIndex:-1 animated:NO];
			[[self incoming] dismissWithClickedButtonIndex:-1 animated:NO];
			[self setEmitting: nil]; [self setIncoming: nil];
			
			[self createCallView];
			[self addCallView];

			[[AlertSystem sharedAlert] stopRinging];
			[[AlertSystem sharedAlert] dismissLocalNotification];
			
		});
	}
}

- (void)dgStatusChange:(appStatus)status
{
	NSLog(@">>> %s %@", __FUNCTION__, statusName(status));
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (status) {
			default:
			case sta_notConnected: //not connected, not connecting
				//auth interface
				[[self l_connectionStatus] setText:@"Not connected"];
				[[self tf_mobileappid]setText:[[DataGroup instance] URLRef]];
				[[self tf_mobileappid]setEnabled:YES];
				[[self tf_mobileappid]setHidden:NO];
				[[self tf_UID]setText:[[DataGroup instance] token]];
				[[self tf_UID]setEnabled:YES];
				[[self tf_UID]setHidden:NO];
				[[self tf_displayname]setText:[[DataGroup instance] displayname]];
				[[self tf_displayname]setEnabled:YES];
				[[self tf_displayname]setHidden:NO];
				
				[[self b_connect]setEnabled:YES];
				[[self b_connect]setTitle:@"Press to connect" forState:UIControlStateNormal];

				
				//call interface
				[[self tf_contactid]setEnabled:NO];
				[[self tf_contactid]setHidden:YES];
				[[self b_call]setEnabled:NO];
				[[self b_call]setHidden:YES];
				[[self b_check]setEnabled:NO];
				[[self b_check]setHidden:YES];
				break;
			case sta_connecting: //connecting
				[[self l_connectionStatus] setText:@"Connecting..."];
				[[self tf_mobileappid]setEnabled:NO];
				[[self tf_mobileappid]setHidden:NO];
				[[self tf_UID]setEnabled:NO];
				[[self tf_UID]setHidden:NO];
				[[self tf_displayname]setEnabled:NO];
				[[self tf_displayname]setHidden:NO];
				[[self b_connect]setEnabled:NO];
				[[self b_connect]setTitle:@"Please Wait..." forState:UIControlStateNormal];
				//call interface
				[[self tf_contactid]setEnabled:NO];
				[[self tf_contactid]setHidden:YES];
				[[self b_call]setEnabled:NO];
				[[self b_call]setHidden:YES];
				[[self b_check]setEnabled:NO];
				[[self b_check]setHidden:YES];
				break;
			case sta_authenticating:
			case sta_connected: //connected, not authenticated
				[[self l_connectionStatus] setText:@"Authenticating..."];
				[[self tf_mobileappid]setEnabled:NO];
				[[self tf_mobileappid]setHidden:YES];
				[[self tf_UID]setEnabled:NO];
				[[self tf_UID]setHidden:NO];
				[[self tf_displayname]setEnabled:NO];
				[[self tf_displayname]setHidden:NO];
				[[self b_connect]setEnabled:NO];
				[[self b_connect]setTitle:@"Please Wait..." forState:UIControlStateNormal];
				//
				[[self tf_contactid]setEnabled:NO];
				[[self tf_contactid]setHidden:YES];
				[[self b_call]setEnabled:NO];
				[[self b_call]setHidden:YES];
				[[self b_check]setEnabled:NO];
				[[self b_check]setHidden:YES];
				break;
				
			case sta_authenticated: //connected & authenticated
			{
				BOOL isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
				NSString *declaration = [NSString stringWithFormat:@"%@%@ (%@)",isPad?@"Connected as: ":@"", [[DataGroup instance] displayname], [[DataGroup instance] token]];
				[[self l_connectionStatus] setText:declaration];
				[[self tf_mobileappid]setEnabled:NO];
				[[self tf_mobileappid]setHidden:YES];
				[[self tf_UID]setEnabled:NO];
				[[self tf_UID]setHidden:YES];
				[[self tf_displayname]setEnabled:NO];
				[[self tf_displayname]setHidden:YES];
				[[self b_connect]setEnabled:YES];
				[[self b_connect]setTitle:@"Press to disconnect" forState:UIControlStateNormal];
				
				[[self tf_contactid]setEnabled:YES];
				[[self tf_contactid]setHidden:NO];
				[[self b_call]setEnabled:YES];
				[[self b_call]setHidden:NO];
				[[self b_check]setEnabled:YES];
				[[self b_check]setHidden:NO];
				break;
			}
			case sta_disconnecting: //Disconnecting
			{
				[[self l_connectionStatus] setText:@"Disconnecting..."];
				[[self tf_mobileappid]setHidden:YES];
				[[self tf_mobileappid]setEnabled:NO];
				[[self tf_UID]setEnabled:NO];
				[[self tf_UID]setHidden:YES];
				[[self tf_displayname]setEnabled:NO];
				[[self tf_displayname]setHidden:YES];
				[[self b_connect]setEnabled:NO];
				[[self b_connect]setTitle:@"Please Wait..." forState:UIControlStateNormal];
				[[self tf_contactid]setEnabled:NO];
				[[self tf_contactid]setHidden:YES];
				[[self b_call]setEnabled:NO];
				[[self b_call]setHidden:YES];
				[[self b_check]setEnabled:NO];
				[[self b_check]setHidden:YES];
				break;
			}
		}
	});
}

- (void)dgDisplayMessage:(NSString *)message during:(float)timer
{
	[[AlertSystem sharedAlert] displayMessage:message during:timer inView:[self view] animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self view]endEditing:YES];
}

@end

