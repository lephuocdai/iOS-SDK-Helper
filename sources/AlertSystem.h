
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#define ALERT_EMIT @"Calling ..."
#define ALERT_INCO @"Call Incoming"

typedef enum
{
	av_checking = 0,
	av_canBeCalled,
	av_cannotBeCalled
} contactAvailability_t;

/**
 * This class deals with call notifications (ringtones and UILocalNotification). This is not thread safe (i.e. it will not deal nicely with creating two alerts at the same time.)
 * \todo It should probably deal with the connection loss alert, too.
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

/**
 * Displays a popup view.
 * \param message the message to be displayed
 * \param timer the time (in seconds) during which the popup will be displayed
 * \param targetSuperview the view that displays the popup
 * \param animated YES means the popup appereance will fadein/fadeout
 */
- (void)displayMessage:(NSString *)message during:(float)timer inView:(UIView *)targetSuperview animated:(BOOL)animated;



@end
