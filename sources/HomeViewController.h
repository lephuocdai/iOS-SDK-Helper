//
//  SchemeControllerViewController.h
//  sdk-helper
//
//  Created by Charles Thierry on 9/24/13.
//  Copyright (c) 2013 Weemo SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallViewController.h"
#import <MessageUI/MessageUI.h>
static NSString *mailSubject  =@"WeemoSDK Helper iPhoneOS %@ %@ %@";
static NSString *mailRecipients = @"mobilesdk@weemo.com";

@interface HomeViewController : UIViewController <UITextFieldDelegate, contactProtocol, loginProtocol, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) CallViewController *cvc_active;

@property (nonatomic, weak) IBOutlet UIButton *b_logo;
@property (nonatomic, weak) IBOutlet UILabel *l_connectionStatus;

@property (nonatomic, weak) IBOutlet UITextField *tf_UID;
@property (nonatomic, weak) IBOutlet UITextField *tf_mobileappid;
@property (nonatomic, weak) IBOutlet UITextField *tf_displayname;
@property (nonatomic, weak) IBOutlet UIButton *b_connect;

@property (nonatomic, weak) IBOutlet UITextField *tf_contactid;
@property (nonatomic, weak) IBOutlet UIButton *b_call;
@property (nonatomic, weak) IBOutlet UIButton *b_check;
@property (nonatomic, weak) IBOutlet UIView *v_allview;

@property (nonatomic) BOOL isFullscreen;

/**
 * Will be called by the not-yet-displayed callView to dismiss the UIAlert and display the view.
 */
- (void)callBecameActive;

- (IBAction)appSite:(id)sender;

- (IBAction)connect:(id)sender;

- (IBAction)call:(id)sender;


@end
