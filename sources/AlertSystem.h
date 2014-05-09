
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#define ALERT_EMIT @"Calling ..."
#define ALERT_INCO @"Call Incoming"

/**
 * This class deals with call notifications (ringtones and UILocalNotification).
 * \todo It should probably deal with the UIAlerts, too.
 * \todo Should not destroy soundsystem elements upon ringing stop.
 */
@interface AlertSystem : NSObject <UIAlertViewDelegate>


+ (AlertSystem *)sharedAlert;

/**
 * Plays the ringing tune. Starts playing once the contact is deemed callable.
 */
- (void)startRinging;

/**
 * Plays the proceeding sound. Will be played until the contact status is unknown.
 */
- (void)startProceeding;

/**
 * Stop the ringing/proceeding sound.
 */
- (void)stopRinging;

/**
 * Dismisses the ln_callincoming displayed and sets it to nil.
 */
- (void)dismissLocalNotification;

/**
 * Creates a local notification displaying the name of the contact and displays it.
 */
- (BOOL)displayLocalNotification:(NSString *)contactDisplayName;

@end
