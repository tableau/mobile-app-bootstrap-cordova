# Tableau Mobile App Bootstrap
-----------------

Provides example code for how to embed vizzes inside of a hybrid web app.

# Contents
-----------------

[Installation](#installation)  

[Development](#customization)  

[Authentication](#authentication)

[Known Issues](#issues)  

[Support](#support)


<a name="installation"/>
# Installation
-----------------

This section will guide you through the process of setting up your development environment and running the Tableau Sample App in the simulator.

## Prerequisites

At the moment, the sample app is only available for iOS. 
1. Install [Node.js](https://nodejs.org/en/)
2. Install Bower `$ sudo npm install -g bower`
3. Install Cordova `$ sudo npm install -g cordova` 
4. Install the required [iOS development tools](http://cordova.apache.org/docs/en/latest/guide/platforms/ios/index.html#installing-the-requirements )
5. Install Ionic `$ sudo npm install -g ionic`
6. Install [Git](https://git-scm.com/downloads)

## Starting the Tableau Sample App
1. Download the code for the app from the [git repo](https://gitlab.tableausoftware.com/avertin/custom-app/tree/inappbrowser_signin)
2. Use terminal to navigate to the folder containing the code from the git repo. Add iOS as a platform by entering the command `$ ionic platform add ios`
3. Build the app by entering in the command `$ ionic build ios`
3. Run the simulator `$ ionic emulate ios --target='iPad-Air' -l -c -s` The flags set up a live reload server so that saved changes in the HTML, CSS, and JavaScript in the www folder will reflect in the app. You may be prompted to select an address to run the simulator on. Selecting any of the options is fine.  You may need to refresh the simulator by entering the command 'r' if the app appears partially blank after updating. 

## Deploying on a Device
Open TableauSampleApp.xcodeproj which is located in platforms/ios. This will open Xcode. Plug in the target device with a USB cable. In terminal, run `$ ionic prepare ios`.  Then build the app in Xcode.

## Learning about the Frameworks
*Cordova/Phonegap* 

In short, Cordova/Phonegap allows developers to create mobile applications using HTML, CSS, and JavaScript.  It is useful for building web hybrid and native hybrid mobile apps. For more detailed information, check out this [Phonegap post](http://phonegap.com/blog/2015/03/12/mobile-choices-post1/). It is also useful to understand the [difference between Cordova and Phonegap](http://phonegap.com/blog/2012/03/19/phonegap-cordova-and-what-e2-80-99s-in-a-name/).


*Ionic*

Ionic provides a lot of useful UI features to speed up development and create a more native feeling app experience. It leverages Angular JS to create custom directives with built in styling. For more information about where Ionic fits in the framework please refer to [this Ionic post](http://blog.ionic.io/where-does-the-ionic-framework-fit-in/).

<a name="customization"/>
# Development
-----------------

Now that you've successfully built the sample app, you are ready to start adding your own vizzes to the app. The majority of the code you can edit lives in the project's 'www' folder. To differentiate Ionic starter code from Tableau added code, look for code with comments that begin with `// TS:`

1. In index.html point the Tableau JavaScript API to your server. For information about which how to do this, visit the  [Tableau JavaScript API reference](https://onlinehelp.tableau.com/current/api/js_api/en-us/JavaScriptAPI/js_api_concepts_get_API.htm?Highlight=min).
 `<script src="https://online.tableau.com/javascripts/api/tableau-2.min.js"></script>`
2. In www/js/config.js edit the config variable to point to your server's sign in page and the vizzes that you want displayed in the app. Most servers enable clickjacking protection which prevents viz urls that include '#' in them from being loaded in cross-domain iframes. To allow the viz to load in the app follow [these instructions](http://kb.tableau.com/articles/knowledgebase/embed-views-clickjack-protection) for modifying the url.
`.constant('config', {
    demo:  false,
    signInUrl: "https://tableau.example.com/#/signin?externalRedirect=%2Fprojects",
    serverUrl: "https://tableau.example.com",
    sitePath: "sitePath",
    oauth: true,
    viz1Url: 'https://tableau.example.com/views/VizOne?:tooltip=n,
    viz2Url: 'https://tableau.example.com/views/VizTwo?:tooltip=n',
    viz3Url: 'https://tableau.example.com/views/VizThree?:tooltip=n'
})` 
3. To change the icons and splash screen follow [these Ionic docs](http://ionicframework.com/docs/cli/icon-splashscreen.html)
4. Customize the UI 

*  Ionic comes with lots of built in [UI options](http://ionicframework.com/docs/components/#header). The basic themes of these UI options can also be overridden using [Sass](http://ionicframework.com/docs/v2/theming/overriding-ionic-variables/) to create a customized look and feel.

*  Swap out the info in the home page by editing the HTML in tab-home.html and adding your assets to www/img

*  To add more tabs, create the html for the content of the tab. Replicate the design of the tabs with vizzes if you wish to embed Tableau content. Add the tab to tabs.html to include it in the DOM and give the tab a controller in www/js/controllers.js. Finally, update www/js/app.js to include the url for the viz in the config variable and add the tab as a state to the $stateProvider. 

*  We highly recommend using [Device Specific Dashboards](http://www.tableau.com/about/blog/2016/6/device-designer-56018) to customize how your viz displays on a phone and tablet.

*  Adding more functionality to the toolbar of the viz is easy using the [Tableau JavaScript API](http://onlinehelp.tableau.com/current/api/js_api/en-us/JavaScriptAPI/js_api.htm). See www/js/directives.js for more information.
 
<a name="authentication"/>
# Authentication
-----------------

Before loading a viz with the Tableau JavaScript API it is important to make sure that the user is properly signed in. 

A Tableau plugin (available soon) was developed for Cordova to handle three authentication related tasks. 
1. Check the user's sign in status.
2. Sign the user out.
3. Keep the user continuously signed in with oauth tokens (this is optional depending on your config options in the app and on your server). 

The plugin's interface is wrapped in an Angular JS service. The service is located in www/js/services.js. For examples about how to use the service, check out www/js/controllers.js.

## OAuth
A Tableau plugin (available soon) also allows the app to keep users signed in with OAuth tokens. Although the plugin interfaces with JavaScript, it is written in Objective-C and may also be useful for developers with Native applications as a stand alone component. To locate the Objective-C files navigate to src/ios/TableauOAuth.m 

For more information about OAuth and the Objective-C class, visit the [project wiki](https://gitlab.tableausoftware.com/avertin/tableau-oauth-plugin/wikis/home).

## InAppBrowser Sign In
To complete the initial user sign in, the app uses [Cordova's InAppBrowser plugin](https://cordova.apache.org/docs/en/latest/reference/cordova-plugin-inappbrowser/) with a few small modifications. These modifications tell the InAppBrowser to close the sign in window automatically once it detects user sign in. The code that handles this logic is located in plugins/cordova-plugin-inappbrowser/src/ios/CDVInAppBrowser.m. 

<a name="issues"/>
# Known Issues
-----------------

1. The 'View Data' option in tooltip overrides the current view of the app. To avoid this issue, disable the tooltip by appending the parameter ':tooltip=n' to the end of the viz urls.
2. No error handling for user with valid credentials but incorrect permissions for viewing the vizzes.
3. Device rotation does not work. This is unfortunately a Cordova bug but can be fixed by updating the plist settings in Xcode to allow rotation.
3. The app does not support offline content.

<a name="support"/>
# Support
-----------------

This collection is not officially 'blessed' by Tableau Engineering or Support. What does that mean? We didn't have a QA team test it. It's a tool for learning how to embed vizzes inside a mobile application. You should not expect that there are 0 bugs.

If you have problems getting it to work, feel free to email us with questions, but we can't promise quick responses.

A standard disclaimer: mobile-app-bootstrap is made available AS-IS with no support and no warranty whatsoever. Despite efforts to write good and useful code there may be bugs that cause unexpected and undesirable behavior. The software is strictly “use at your own risk.”

The good news: This is intended to be a self-service tool. You are free to modify it in any way to meet your needs.
