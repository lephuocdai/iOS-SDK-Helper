//
//  DataGroup.m
//  sdk-helper
//
//  Created by Charles Thierry on 9/17/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import "DataGroup.h"
#import "AppDelegate.h"

#import <sys/sysctl.h>
#import "AlertSystem.h"




static id instance = NULL;

@implementation DataGroup

+ (id)instance
{
    static dispatch_once_t dataGroupToken;
	
    dispatch_once(&dataGroupToken, ^{
		instance = [[DataGroup alloc] init];
	});
	return instance;
}

- (id)init
{
	if (instance) return instance;
	self = [super init];
	if (self)
	{
		_status = sta_notConnected;
		connectionParameters = [(AppDelegate *)[[UIApplication sharedApplication] delegate] launchParameters];
		if (![[connectionParameters objectForKey:KEY_TOKEN] isEqualToString:@""] &&
			[[connectionParameters objectForKey:KEY_MOBILEAPPID] isEqualToString:@""])
		{
			[self connect];
		}
		//autolaunch mode
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnect) name:kLaunchURL object:nil];
	}
	return self;
}

- (void)initiateWithParameters:(NSDictionary*)parameters
{
	[[self loginDelegate] dgStatusChange:_status];
	connectionParameters = parameters;
	[self connect];
}

- (BOOL)signOut
{
	BOOL retValue = NO;
	if ([[Weemo instance] isConnected])
	{
		[[Weemo instance] disconnect];
		connectionParameters = nil;	
		retValue = YES;
	}

	return retValue;
}

- (void)doDisconnect
{
//	if ([[Weemo instance] isConnected])
//	{
		_status = sta_disconnecting;
		[[self loginDelegate] dgStatusChange:_status];
		[[self contactDelegate] dgCallStatusChange:nil];
		connectionParameters = nil;
		callParameters = nil;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
			[[Weemo instance] disconnect];
		});
//	}
}

- (void)checkAvailable:(NSString *)contact
{
	[[Weemo instance] getStatus:contact];
}


- (NSString *)token
{
	if ([connectionParameters objectForKey:KEY_TOKEN] != nil)
		return [connectionParameters objectForKey:KEY_TOKEN];
	else return platformType();
}

- (NSString *)URLRef
{
	if ([connectionParameters objectForKey:KEY_MOBILEAPPID] != nil)
		return [connectionParameters objectForKey:KEY_MOBILEAPPID];
	else return DEFAULTKEY;
}


- (NSString *)displayname
{
	if ([connectionParameters objectForKey:KEY_DISPLA] != nil)
		return [self getEscapedContact:[connectionParameters objectForKey:KEY_DISPLA]];
	else return platformString();
}

- (void)call:(NSString *)contact
{
	if (contact == NULL || [contact isEqualToString:@""]) return;
	[[Weemo instance] createCall:contact];
}

- (void)reconnect
{
	[self signOut];
	connectionParameters = [(AppDelegate *)[[UIApplication sharedApplication] delegate] launchParameters];
	[self connect];
}

- (void)connect
{
	if (![self signOut])
	{
		_status = sta_connecting;
		NSError *err;
		[[self loginDelegate] dgStatusChange:_status];
		[Weemo WeemoWithAppID:[connectionParameters objectForKey:KEY_MOBILEAPPID] andDelegate:self error:&err];
		if (err)
		{
			NSLog(@"%s %@", __FUNCTION__, err);
			_status = sta_notConnected;
			[[self loginDelegate] dgStatusChange:_status];
		}
	}
}

- (NSString *)getEscapedContact:(NSString *)contact
{
	if (!contact) return nil;
	NSMutableString *nsms = [NSMutableString stringWithString:contact];
	NSRange test = NSMakeRange(0, [contact length]);
	[nsms replaceOccurrencesOfString:@"%20" withString:@" " options:NSCaseInsensitiveSearch range:test];
	return nsms;
}



#pragma mark - UIAlertView delegation
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView == av_lostConnection && buttonIndex == 0)
	{
			[[DataGroup instance] doDisconnect];
			connectionParameters = nil;
		}
	}

#pragma mark - Weemo Delegation

- (void)weemoDidConnect:(NSError *)error
{
	_status = error? sta_notConnected : sta_connected;
	[[self loginDelegate] dgStatusChange:_status];
	if ([[self loginDelegate] respondsToSelector:@selector(dgDidConnect:)])
		[[self loginDelegate] dgDidConnect:error];
	if (error)
	{
		NSLog(@">>> %s %@", __FUNCTION__, error);
		return;

	} else if ([connectionParameters objectForKey:KEY_TOKEN])
	{

		[[Weemo instance] authenticateWithToken:[connectionParameters objectForKey:KEY_TOKEN]
									   andType:USERTYPE_INTERNAL];
		[[self loginDelegate] dgStatusChange:sta_authenticating];
	}
}

- (void)weemoDidAuthenticate:(NSError *)error
{
	NSString *displayname;
	dispatch_async(dispatch_get_main_queue(), ^{
		if (av_lostConnection)
		{
			[av_lostConnection dismissWithClickedButtonIndex:-1 animated:YES];
			av_lostConnection = nil;
		}
	});
	NSLog(@">>> %s %@ -- call %@", __FUNCTION__, error, [[Weemo instance] activeCall]);
	if (connectionParameters)
	{
		if ([[connectionParameters allKeys]containsObject:KEY_DISPLA])
		{
			displayname = [NSMutableString stringWithString:[connectionParameters objectForKey:KEY_DISPLA]];
		} else {
			displayname = [NSMutableString stringWithString:[connectionParameters objectForKey:KEY_TOKEN]];
		}
	}
	_status = error? sta_notConnected:sta_authenticated;
	[[self loginDelegate] dgStatusChange:_status];
	if (error)return;
	[[Weemo instance] setDisplayName:[self getEscapedContact:displayname]];
	if ([[self loginDelegate] respondsToSelector:@selector(dgDidAuthenticate:)])
		[[self loginDelegate] dgDidAuthenticate:error];
}


- (void)weemoDidDisconnect:(NSError *)error
{
	NSLog(@">>> %s %@ (%@)", __FUNCTION__, error, statusName([self status]));
	//here we deal with connection loss...
	switch ([self status]) {
		case sta_notConnected:
		case sta_disconnecting:
			_status = sta_notConnected;
			[[self loginDelegate] dgStatusChange:_status];
			if ([[self loginDelegate] respondsToSelector:@selector(dgDidDisconnect:)])
				[[self loginDelegate] dgDidDisconnect:error];
			break;
		default:
		{	//Disconnection while not trying to disconnect -> problem
			if (!av_lostConnection)
			{
				av_lostConnection = [[UIAlertView alloc]initWithTitle:@"???"
															  message:@"Network loss, please stand-by while we try reconnecting you."
															 delegate:self
													cancelButtonTitle:@"Cancel"
													otherButtonTitles: nil];
			
				dispatch_async(dispatch_get_main_queue(), ^{
					[av_lostConnection show];
				});
			}
		} break;
	}
}


- (void)weemoCallCreated:(WeemoCall *)call
{
	[[self contactDelegate] dgCallStatusChange:call];
}

- (void)weemoCallEnded:(WeemoCall *)call
{
	if ([call callStatus] != CALLSTATUS_ENDED && call)
	{
		NSLog(@">>> Weemo signaled the call terminated while callStatus != CALLSTATUS_TERMINATED -> network disconnection");
	} else {
		[[self contactDelegate] dgCallStatusChange:call];
	}

}

- (void)weemoContact:(NSString *)contactID canBeCalled:(BOOL)canBeCalled
{
	[[self contactDelegate] dgContact:contactID canBeCalled:canBeCalled];
}


#pragma mark - Application Delegate
- (void)setLoginDelegate:(id<loginProtocol>)ld
{
	_loginDelegate = ld;
}

- (void)setContactDelegate:(id<contactProtocol>)cd
{
	_contactDelegate = cd;
	[[self loginDelegate] dgStatusChange:_status];
}

@end
