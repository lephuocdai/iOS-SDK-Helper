//
//  CallViewController.h
//  sdk-helper
//
//  Created by Charles Thierry on 7/19/13.

/**
 * The call view displays the VideoIn (Incoming) and VideoOut (Monitor/Outgoing) videos.
 *
 */

@interface CallViewController : UIViewController <WeemoCallDelegate>
{
	BOOL fillVideo;
}
@property (weak, nonatomic) IBOutlet UIButton *b_hangup;
@property (weak, nonatomic) IBOutlet UIButton *b_profile;
@property (weak, nonatomic) IBOutlet UIButton *b_toggleVideo;
@property (weak, nonatomic) IBOutlet UIButton *b_toggleAudio;
@property (weak, nonatomic) IBOutlet UIButton *b_switchVideo;

/**
 * Displays the inbound video
 */
@property (weak, nonatomic) IBOutlet UIView *v_videoIn;
/**
 * Displays the outbound video
 */
@property (weak, nonatomic) IBOutlet UIView *v_videoOut;

@property (weak, nonatomic) IBOutlet UIView *v_callMenu;

/**
 * Weak link to the WeemoCall. Equivalent to [[Weemo instance] activeCall]
 */
@property (weak, nonatomic) WeemoCall *call;

/**
 * The user tapped on the "Hangup" button
 */
- (IBAction)hangup:(id)sender;

/**
 * The user tapped on the "HD" button
 */
- (IBAction)profile:(id)sender;

/**
 * The user tapped on the "Enable Video"
 */
- (IBAction)toggleVideo:(id)sender;

/**
 * The user tapped on the "Switch" button
 */
- (IBAction)switchVideo:(id)sender;

/**
 * The user tapped on "Enable Mic." button
 */
- (IBAction)toggleAudio:(id)sender;

@end
