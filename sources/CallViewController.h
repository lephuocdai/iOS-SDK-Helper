//
//  CallViewController.h
//  sdk-helper
//
//  Created by Charles Thierry on 7/19/13.


@interface CallViewController : UIViewController <WeemoCallDelegate>

@property (weak, nonatomic) IBOutlet UIButton *b_hangup;
@property (weak, nonatomic) IBOutlet UIButton *b_profile;
@property (weak, nonatomic) IBOutlet UIButton *b_toggleVideo;
@property (weak, nonatomic) IBOutlet UIButton *b_toggleAudio;
@property (weak, nonatomic) IBOutlet UIButton *b_switchVideo;

@property (weak, nonatomic) IBOutlet UIView *v_videoIn;
@property (weak, nonatomic) IBOutlet UIView *v_videoOut;


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


#pragma mark - WeemoCallDelegate
//Two methods of the delegate are not implemented
- (void)weemoCall:(id)sender videoReceiving:(BOOL)isReceiving;
- (void)weemoCall:(id)sender videoSending:(BOOL)isSending;
- (void)weemoCall:(id)sender videoProfile:(int)profile;
- (void)weemoCall:(id)sender callStatus:(int)status;
- (void)weemoCall:(id)call audioSending:(BOOL)isSending;
- (void)weemoCall:(id)sender videoSource:(int)source;
@end
