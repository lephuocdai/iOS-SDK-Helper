//
//  AppDelegate.m
//  sdk-helper
//
//  Created by Charles Thierry on 7/16/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import "AppDelegate.h"
#import "AlertSystem.h"

#import <CrashReporter/CrashReporter.h>

@implementation AppDelegate
{
	NSDictionary *lp;
}

//creates a dictionary with the query elements. based on the fact the URL is something like scheme://?query1=a&query2=b
//the answer will be a dictionary [{object,key}] == [{a, query1}, {b, query2}]
- (NSDictionary *)parseURL:(NSURL *)entry
{
	NSMutableDictionary *connectionParameters = [[NSMutableDictionary alloc]init];
	//PFM
	[connectionParameters setObject:[entry host] forKeyedSubscript:KEY_PFMHOST];
	[connectionParameters setObject:[entry path] forKeyedSubscript:KEY_PFMPATH];
	
	//launchArguments
	if ([entry query] == nil || [[entry query]isEqualToString:@""]) return connectionParameters;
	NSArray * parameters = [[entry query] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"&="]];
	
	if (!([parameters count] & 1))
	{
		NSMutableArray * keys = [NSMutableArray array];
		NSMutableArray * values = [NSMutableArray array];
		[parameters enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([obj isEqualToString:@""]) return;
			if( idx & 1 )
			{
				[values addObject:obj];
			} else {
				[keys addObject:obj];
			}
		}];
		uint8_t miniCount = fminf([keys count], [values count]);
		for (uint8_t l = 0; l < miniCount; l++)
		{
			[connectionParameters setObject:[values objectAtIndex:l] forKey:[keys objectAtIndex:l]];
		}
	}
	return connectionParameters;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	if (!launchOptions)
	{
		NSArray * args = [[NSProcessInfo processInfo] arguments];
		if ([args count]>1)
		{
			lp =[self parseURL:[NSURL URLWithString:[args objectAtIndex:1]]];
		}
	} else {
		NSLog(@"%@", [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]);
		lp = [self parseURL:[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]];
	}
	[[PLCrashReporter sharedReporter] enableCrashReporter];
	return YES;
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	lp = [self parseURL:url];
	[[NSNotificationCenter defaultCenter] postNotificationName:kLaunchURL object:self];
	
	return YES;
}

- (NSDictionary *)launchParameters
{
	return lp;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
