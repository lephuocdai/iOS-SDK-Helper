# Content

This document comes in addition to the [SDK wiki](https://github.com/weemo/iOS-SDK/wiki) and [doxygen documentation](http://docs.weemo.com/sdk/ios) of the Weemo SDK for iOS project.

This sample project is provided with the usual disclaimer about how it comes `WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED`, as per the MIT License.

The goal of this sample project is to give developers a working example of how to start the Weemo singleton, connect and disconnect, authenticate on our network, and place an audio/video call, and to keep it simple.

Please see the [wiki](https://github.com/weemo/iOS-SDK-Helper/wiki) for more details regarding the implementation of the Helper.

Please note that, as this application needs a video capture hardware to be used, it can not be used on the iPhone Simulator -- you must run it on an actual device.

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

Define the Mobile App ID as `MOBILEAPPID` in the `support/sdk-helper-Prefix.pch` file, and start the compilation. It should run without error.
