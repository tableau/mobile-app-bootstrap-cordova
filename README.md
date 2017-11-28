# Mobile App Bootstrap

[![Community Supported](https://img.shields.io/badge/Support%20Level-Community%20Supported-457387.svg)](https://www.tableau.com/support-levels-it-and-developer-tools)

Provides example code for how to embed Tableau vizzes inside of a hybrid web app.

## Contents

[Prerequisites](#Prerequisites)

[Installation](#installation)

[Customization](#customization)

[Authentication](#authentication)

[Debugging](#debugging)

[Known Issues](#known-issues)

[Support](#support)

## Prerequisites
At the moment, the Mobile App Bootstrap is only supported on iOS. While the app can compile and run on Android; the [Connected Client Plugin](https://github.com/tableau/mobile-connected-client) is currently only available on iOS.

## Installation

This section will guide you through the process of setting up your iOS development environment and running the Mobile App Bootstrap in the simulator.

1. Install [Node.js](https://nodejs.org/en/)
2. Install Bower
`$ sudo npm install -g bower`
3. Install Cordova
`$ sudo npm install -g cordova`
4. Install the required [iOS development tools](http://cordova.apache.org/docs/en/latest/guide/platforms/ios/index.html#installing-the-requirements )
5. Install Ionic
`$ sudo npm install -g ionic`
6. Install [Git](https://git-scm.com/downloads)

### Starting the Tableau Sample App

1. Download the code for the app from this [repository](https://github.com/tableau/mobile-app-bootstrap-cordova)
2. Use Terminal to navigate to the root folder containing the code
3. Ensure the `add_platform_class.js` file has the execute permission:  
`$ chmod a+x hooks/after_prepare/010_add_platform_class.js`
4. Add the ionic iOS framework to the project:  
`$ ionic cordova platform add ios`
(confirm when asked to install .node_modules)
5. Build the app for the iOS platform. (If you see an `***ARCHIVE FAILED***` error message, see [Known Issues](#known-issues) # 7)  
`$ ionic cordova build ios` 
6. Run the simulator:  
`$ ionic cordova emulate ios --target='iPad-Air' -l -c -s`  
The flags set up a live reload server so that saved changes in the HTML, CSS, and JavaScript in the www folder will reflect in the app. You may be prompted to select an address to run the simulator on. Selecting any of the options is fine.  You may need to refresh the simulator by entering the command 'r' if the app appears partially blank after updating. You can see other emulators that are available by running the following command from the root folder of the project:  
`$ ./platforms/ios/cordova/lib/list-emulator-images`

### Deploying on a Device

Open `platforms/ios/TableauSampleApp.xcodeproj`. This will open Xcode. Plug in the target device with a USB cable. In Terminal, run:  
`$ ionic cordova prepare ios`  
Then build the app in Xcode.

### Learning about the Frameworks

*Cordova/Phonegap*  
Cordova/Phonegap allows developers to create mobile applications using HTML, CSS, and JavaScript. It is useful for building web hybrid and native hybrid mobile apps. For more detailed information, check out this [Phonegap post](http://phonegap.com/blog/2015/03/12/mobile-choices-post1/). It is also useful to understand the [difference between Cordova and Phonegap](http://phonegap.com/blog/2012/03/19/phonegap-cordova-and-whate28099s-in-a-name/).

*Ionic*  
Ionic provides many useful UI components to speed up development and create a more native feeling app experience. It leverages Angular JS to create custom directives with built-in styling. For more information about where Ionic fits in the framework, refer to this [Ionic post](http://blog.ionic.io/where-does-the-ionic-framework-fit-in/).

*Bower*  
Bower is a package manager that manages components that contain HTML, CSS, JavaScript, fonts or even image files. Bower doesn’t concatenate or minify code or do anything else - it just installs the right versions of the packages you need and their dependencies. For more information about where Bower fits in the framework, refer to the [Bower site](https://bower.io/).

## Customization

Now that you've successfully built the sample, you are ready to start adding your own dashboards to the app and/or customize it. The majority of the code you can edit lives in the project's `www` folder. To differentiate Ionic starter code from Tableau-added code, look for code with comments that begin with `// TS:`

1. In `index.html`, point the Tableau JavaScript API to your server. For information about how to do this, visit the  [Tableau JavaScript API reference](https://onlinehelp.tableau.com/current/api/js_api/en-us/JavaScriptAPI/js_api_concepts_get_API.htm?Highlight=min).
 `<script src="https://online.tableau.com/javascripts/api/tableau-2.min.js"></script>`

2. In `www/js/config.js` edit the config variable to point to your server's sign in page and the vizzes that you want displayed in the app.
```javascript
.constant('config', {
    demo:  false,
    signInUrl: "https://tableau.example.com/#/signin?externalRedirect=%2Fprojects",
    serverUrl: "https://tableau.example.com",
    sitePath: "sitePath",
    oauth: true,
    viz1Url: 'https://tableau.example.com/views/VizOne?:tooltip=n',
    viz2Url: 'https://tableau.example.com/views/VizTwo?:tooltip=n',
    viz3Url: 'https://tableau.example.com/views/VizThree?:tooltip=n'
})
```

Note: Most servers enable clickjacking protection which prevents URLs that include '#' from being loaded in cross-domain iframes. To allow a viz to load in the app follow [these instructions](http://kb.tableau.com/articles/knowledgebase/embed-views-clickjack-protection) for modifying the url.

3. To change the icons and splash screen, follow [these Ionic docs](http://ionicframework.com/docs/cli/icon-splashscreen.html)

4. Customize the UI

    * Ionic comes with lots of built-in [UI options](http://ionicframework.com/docs/components/#header). The basic themes of these UI options can also be overridden using [Sass](http://ionicframework.com/docs/v2/theming/overriding-ionic-variables/) to create a customized look and feel.

    * Ionic also comes with lots of built-in [icons](http://ionicons.com). To assign an icon to a tab, edit `tabs.html` and assign your own `icon-on` and `icon-off` values. For example: `icon-on="ion-map"` would display the Ionic map icon when that tab is selected.

    * Swap out the content in the home page by editing the HTML in `tab-home.html` and adding your assets to `www/img/`

    * To add more tabs, create the html for the content of the tab. Replicate the design of the tabs with vizzes if you wish to embed Tableau content. Add the tab to `tabs.html` to include it in the DOM and give the tab a controller in `www/js/controllers.js`. Finally, update `www/js/app.js` to include the url for the viz in the config variable and add the tab as a state to the `$stateProvider`.

    * We highly recommend using the new [Device Designer](http://www.tableau.com/about/blog/2016/6/device-designer-56018) capability in Tableau 10 to customize how your viz displays on a phone and tablet.

    * Adding more functionality to the toolbar of the viz is easy using the [Tableau JavaScript API](http://onlinehelp.tableau.com/current/api/js_api/en-us/JavaScriptAPI/js_api.htm). See `www/js/directives.js` for more information.
 
## Authentication

Before loading a viz with the Tableau JavaScript API it is important to make sure that the user is properly signed in. 

The [Mobile-Connected-Client plugin](https://github.com/tableau/mobile-connected-client) has been developed to handle three authentication related tasks.

1. Check the user's sign in status.
2. Sign the user out.
3. Keep the user continuously signed in with long-lived tokens (this is optional depending on your config options in the app and on your server). 

The plugin's interface is wrapped in an Angular JS service. The service is located in `www/js/services.js`. For examples on how to use the service, see `www/js/controllers.js`.

### Long-Lived Tokens

The [Mobile-Connected-Client plugin](https://github.com/tableau/mobile-connected-client) also allows the app to keep users signed in with long-lived tokens. Although the plugin interfaces with JavaScript, it is written in Objective-C and may also be useful for developers with native applications as a stand alone component. To locate the Objective-C files, navigate to `src/ios/TableauOAuth.m`.

For more information about long-lived tokens and the Objective-C class, visit the [project wiki](https://github.com/tableau/mobile-connected-client).

### InAppBrowser Sign In

To complete the initial user sign in, the app uses [Cordova's InAppBrowser plugin](https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-inappbrowser/) with a few small modifications. These modifications tell the InAppBrowser to close the sign in window automatically once it detects user sign in. The code that handles this logic is located in `plugins/cordova-plugin-inappbrowser/src/ios/CDVInAppBrowser.m`. 

## Debugging

Perplexingly, issues can occur in layers with separate debug output: the objective-c app layer, and the HTML/CSS/JS layer.

To debug the objective-c layer, open `platforms/ios/TableauSampleApp.xcodeproj` and run the app from within Xcode.

To debug the HTML layer, use Safari's Developer Tools, enabled in Safari's Preferences->Advanced menu. Via Safari's Develop menu, you can attach Safari's tools to a running simulator or device WebView.

Note:

* `ionic cordova emulate` rewrites the cordova configuration file at `platforms/ios/TableauSampleApp/config.xml` to point at an ionic web server running locally. `ionic cordova build ios` should return `config.xml` to point to the app's bundled index.html file.

* To Safari's debug tools, the app's Sign In page looks like a separate WebView.

* To really debug everything being sent and received by the app, you might enjoy a web debugging proxy like [Fiddler](http://www.telerik.com/fiddler), [Charles](https://www.charlesproxy.com/), or [Burp](https://portswigger.net/burp).

## Known Issues

1. The sample app does not yet have code that provides user authentication support on the Android platform.
2. The 'View Data' option in tooltip overrides the current view of the app. To avoid this issue, disable the tooltip by appending the parameter `:tooltip=n` to the end of the viz URLs.
3. In some cases, switching to a different viz may result in a blank page. Your console may show an error similar to:  `Error: Can't find variable: tableau`.  
The solution is to stop using the JS API from the Server and copy it locally:  
   a) Save `tableau-2.1.0.min.js` to the bootstrap’s `www/js` folder  
   b) Change `index.html` to load this script (instead of the hosted one on the Server)
4. No error handling for a user with valid credentials but incorrect permissions for viewing the vizzes.
5. Device rotation does not work. This is unfortunately a Cordova bug but can be fixed by updating the `.plist` settings in Xcode to allow rotation.
6. The app does not support offline content.
7. Code Signing Error with iOS 11: Double click to open `platforms/ios/TableauSampleApp.xcodeproj`. This will open Xcode. In the general tab, make sure signing is set to 'Automatically manage signing' and select a provisioning profile.


## Support

This collection is supported by the community and not officially 'blessed' by Tableau Engineering or Support. What does that mean? We didn't have a QA team test it. It's a tool for learning how to embed vizzes inside a mobile application. You should not expect that there are 0 bugs.

If you have problems getting it to work, feel free to email us with questions, but we can't promise quick responses. The [Tableau Developer Community](developer.tableau.com) is also a great resource if you need help.

A standard disclaimer: mobile-app-bootstrap is made available AS-IS with no support and no warranty whatsoever. Despite efforts to write good and useful code there may be bugs that cause unexpected and undesirable behavior. The software is strictly “use at your own risk.”

The good news: This is intended to be a self-service tool. You are free to modify it in any way to meet your needs.
