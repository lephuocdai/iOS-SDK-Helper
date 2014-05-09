# Weemo iOS SDK Helper 5.1

This repository hosts the Weemo iOS demonstration program, called the
"sdk_helper", that can be used to get familiar with Weemo technology.

The sdk_helper is a complete XCode project.  It includes example
storyboards, view controllers and images.  It includes precompiled
copies of the code libraries Opus and VP8.  The sdk_helper can be
compiled as is and run directly on your iOS device.

Examining the code of the sdk_helper is a great way to start to learn
about the methods and delegates implemented in a simple Weemo
application.  The example code components can used as a starting point
for building Weemo functionality into an existing app.  In addition,
the Xcode project itself is a useful reference for examining the XCode
"Build Settings" and "Capabilities" that a Weemo app needs.

The goal of this sample project is to give developers a working
example of how to start the Weemo singleton, connect and disconnect,
authenticate on our network and place an audio/video call.

### Fetch the sources

Using "Download ZIP" won't give you anything usable, especially regarding the framework inner architecture. Try to use the CLI on your MacOS computer:

	git clone --recursive git@github.com:weemo/iOS-SDK-Helper.git

This will create a folder named `iOS-SDK-Helper` in the current directory, in wich the helper and the SDK will be downloaded. If you want this folder to be named something else, add the name you want after the `git clone` command, like

	git clone --recursive git@github.com:weemo/iOS-SDK-Helper.git something-else


The SDK is pulled and stored beside the libraries in the WeemoSDK folder.

### Update the sources

From inside the fetched folder:

	git pull
	git submodule update


### IDE Configuration

After you [fetch the sources](#Fetch-the-sources), launch the `sdk-helper.xcodeproj` project stored in the created folder using Xcode. 

# Global Architecture

This project is divided in three classes:

* The `DataGroup` class is represented by a singleton and is the WeemoDelegate. It starts the Weemo singleton.
* The `CallViewController` is the view that appears when a call is placed/is started. It allows the user to change the video/audio source, to start/stop the outgoing audio[^1] and video, and of course hanging up the call. It is a WeemoCallDelegate.
* The `ViewController` is the controller for the rootView of the project.


## DataGroup

The Weemo singleton is initialized in the `- (void)connect:` method of the WeemoDelegate, once the connection parameters are gathered (and only if the MobileAppID and the Token are available).

	…
	[Weemo WeemoWithAppID:[connectionParameters objectForKey:KEY_MOBILEAPPID] andDelegate:self error:nil];
	…

Note that we don't keep a reference to the Weemo singleton, since it can be fetched by simply calling `[Weemo instance]`.

Authentication takes place once the `WeemoDelegate` `- (void)weemoDidConnect:` method is called.

	…
	[[Weemo instance] authenticateWithToken:[connectionParameters objectForKey:KEY_TOKEN]
									   andType:USERTYPE_INTERNAL];
	…

The connection is not done synchronously:the boolean returned by the authentication method depends on <a href=https://github.com/weemo/poc/wiki/Naming-rules>the correctness</a> of the UserID used.

Once the Weemo singleton is connected, the `weemoDidAuthenticate:` is fired with a `nil` parameter.

The Weemo singleton is disconnected once 

	…
	[[Weemo instance] disconnect];
	…
This method disconnected the Weemo singleton from the network. The singleton is not destroyed. To reconnect, simply use the `WeemoWithAPIKey:andDelegate:error:`. The user have to re-authenticate afterwards.



### Delegate

All those methods are called by the Weemo singleton object and implemented in the sample application.

##### `weemoDidConnect:`

On connection success or failure, the `weemoDidConnect:` method is called. In this code, being disconnected triggers a reconnection if the token can be found in the parameters.

##### `weemoDidAuthenticate:`

After authentication success or failure, this method is called. On success, the displayName is set.

##### `weemoDidDisconnect:`
After a disconnection attempt (or a remote disconnection), this method is called.

##### `weemoCallCreated:`

This method is called upon receiving a call (status is `CALLSTATUS_INCOMING`) or upon placing a call (another status `CALLSTATUS_PROCEEDING` or `CALLSTATUS_RINGING`). The call status tells which case applies.

##### `weemoContact:canBeCalled:`
This method is called after the user checks the availability of a contact.

## CallViewController

Once a call has be created and returned to the application, or picked-up, this object's view is displayed on top of the root view controller.

The two UIViews used to display the video streams are set in the `viewWillAppear:` of this ViewController. 
	
	…
	[[self call]setViewVideoIn:[self v_videoIn]];
	[[self call]setViewVideoOut:[self v_videoOut]];
	…
	
Both data streams (audio and video) starts upon call start.
Each buttons of the View is linked to a WeemoCall action: pick-up/hang-up the call, switch Video source, start/stop video capture, start/stop audio capture.

### Delegate

##### `weemoCall:videoReceiving:`
This function is called when the remote client starts or stops its outgoing video stream, allowing you to adapt the GUI of the call view.

##### `weemoCall:videoSending:`
This function is the matching local function of the previous. The client starts or stops its outgoing video stream, allowing you to adapt the GUI of the call view.

##### `weemoCall:videoProfile:`
This function is called when the incoming video changes profile.

##### `weemoCall:videoSource:`
This function is called when the Video source changes.

##### `weemoCall:audioSending:`
This is called after a change in the audio capture. If YES, the client is sending what the microphone is capturing. If NO, the client sends empty audio frames.

##### `weemoCall:callStatus:`
This is called when the status of the call changed, allowing you to remove the callView from the application, using whatever means you want.


A function is not implemented in this example:

##### `weemoCall:audioRoute:`
Called when the audio route changes, upon headset connection.



[^1]: If you read the <a href='https://github.com/weemo/iOS-SDK/wiki'>wiki</a> carefully, you already know that the outgoing audio stream is never really stopped. `audioStop` allows the user to stop sending audio captured from the microphone, but the stream stays open, sending empty frames.


# Using the Helper Application

The sdk_helper application can be used to set up a Weemo call between two devices, or between one device and one browser.  This short "HOWTO" note will describe how to set up a test call between two iOS devices.

A Weemo AppID identifies your application, and also defines a namespace of User-IDs.  To test two endpoints, you use the same AppID on both endpoints, and give each endpoint a unique User-ID.

<p align="center"><img src="http://docs.weemo.com/img/ios-sdk-5.1-helper-frontscreen.png" width="320"></p>

The front screen of the sdk_helper application asks for three pieces of information.  These are:

- AppID: the key given to you by Weemo.
- UID: a User-ID for each endpoint.  (This string should be from 6 to 90 characters in length.)
- Display Name: The full name of the user at each endpoint.


## Instructions for making a call

1. In the first device, enter the AppID, a User-ID and a Display Name. Then press "Connect."

2. In the second device, enter the AppID, a different User-ID and Display Name.  Then press "Connect."

3. Now, make a call from the first device to the second device.  In the "Contact UID" field on the first device, enter the User-ID of the second device.  Press "Call."

You should now be presented with an "Incoming Call" on the second device.  Select "Pick-up" to complete the call.

<p align="center"><img src="http://docs.weemo.com/img/ios-sdk-5.1-helper-secondscreen.png" width="320"></p>


# Miscellaneous Implementation Notes

## Threading

Delegate methods called from the Weemo singleton or a WeemoCall object will be called on an unspecified thread.  Care should be taken when performing operations in callbacks that should be performed on the main thread.  In particular, GUI and URLConnection operations must be performed on the main thread in IOS.

Weemo recommends using blocks and the global dispatch queue for wrapping operations that must be performed on the main thread.

## Layout and Constraints

The SDK Helper uses Storyboards to define its views and Autosizing to define the constraints on its elements.   The CallViewController is responsible for the layout of the "remote" video view, the "local" video view, and the call buttons.

If your project is using iOS "Auto Layout", you will need to manage the constraints on the layout of the elements in this view.



