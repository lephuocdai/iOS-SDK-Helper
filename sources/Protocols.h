//
//  Protocols.h
//  SDK Helper Adv
//
//  Created by Charles Thierry on 1/9/14.
//  Copyright (c) 2014 Weemo SAS. All rights reserved.
//

#ifndef SDK_Helper_Adv_Protocols_h
#define SDK_Helper_Adv_Protocols_h
#include <sys/sysctl.h>

typedef enum
{
	sta_notConnected = 0,
	sta_connecting,
	sta_connected,
	sta_authenticating,
	sta_authenticated,
	sta_incall,
	sta_disconnecting
}appStatus;

inline static
NSString *platformType()
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = (char *)malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	return platform;
}

inline static
NSString * platformString()
{
    NSString *platform = platformType();
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
	if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
	if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
	if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
	if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
	
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
	
	if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
	if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
	
	if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G(WiFi)";
	if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G(Cellular)";
	
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


/**
 * The DidConnect, DidAuthenticate and DidDisconnect are optional and will only be fired after the dgStatusChange is fired with the appropriate status (respectively 2, 3 and 0).
 */
@protocol loginProtocol <NSObject>
- (void)dgStatusChange:(appStatus)status;

@optional
- (void)dgDidConnect:(NSError *)did;
- (void)dgDidAuthenticate:(NSError *)did;
- (void)dgDidDisconnect:(NSError *)did;

@end

@protocol contactProtocol <NSObject>




- (void)dgContact:(NSString *)contactUID canBeCalled:(BOOL)canBe;
- (void)dgCallStatusChange:(WeemoCall *)call;

@end

#endif
