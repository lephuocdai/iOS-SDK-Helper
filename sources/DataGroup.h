//
//  DataGroup.h
//  sdk-helper
//
//  Created by Charles Thierry on 9/17/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

static inline NSString *statusName(appStatus st)
{
	switch (st) {
		case sta_authenticated:
			return @"Authenticated";
		case sta_authenticating:
			return @"Authenticating";
		case sta_connected:
			return @"Connected";
		case sta_connecting:
			return @"Connecting";
		case sta_disconnecting:
			return @"Disconnecting";
		case sta_incall:
			return @"InCall";
		case sta_notConnected:
			return @"NotConnected";
	}
}

@interface DataGroup : NSObject <WeemoDelegate, UIAlertViewDelegate>
{
	NSDictionary *connectionParameters;
	NSDictionary *callParameters;
	UIAlertView *av_lostConnection;
}

@property (nonatomic) appStatus status;
@property (nonatomic, weak) id<loginProtocol> loginDelegate;
@property (nonatomic, weak) id<contactProtocol> contactDelegate;


+ (id)instance;

/**
 * Initiate the control object with parameters
 * Available keys:
 *	KEY_TOKEN		: the default token (contactID)
 *	KEY_MOBILEAPPID	: the mobile app id to use for connection
 *	KEY_DISPLA		: the user's display name
 *
 */
- (void)initiateWithParameters:(NSDictionary*)parameters;

/**
 * Disconnects the user from the network.
 * \return YES if the user was connected, NO otherwise.
 */
- (BOOL)signOut;

/**
 * Disconnects a user, fires the contactDelegate dgStatusChange and cleanses the connection and call parameters.
 */
- (void)doDisconnect;

/**
 * Asks the network if a contact is available. Answer is returned by callback.
 */
- (void)checkAvailable:(NSString *)contact;

- (NSString *)token;
- (NSString *)URLRef;
- (NSString *)displayname;

/**
 * Starts a call to contact.
 */
- (void)call:(NSString *)contact;


@end
