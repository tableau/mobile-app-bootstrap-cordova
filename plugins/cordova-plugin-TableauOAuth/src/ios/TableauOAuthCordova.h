/*
 TableauOAuthCordova
 A Cordova plugin that handles authentication related tasks for the Tableau custom app.
 Communicates with JavaScript interface following Cordova Plugin Development guidelines.
 For more information: https://cordova.apache.org/docs/en/latest/guide/hybrid/plugins/
 */

#ifndef TableauOAuthCordova_h
#define TableauOAuthCordova_h

#import "TableauOAuth.h"
#import <Cordova/CDV.h>

@interface TableauOAuthCordova : CDVPlugin

// CORDOVA SPECIFIC: Handle communication between plugin and JavaScript
- (void)requestOAuthTokensCordova:(nonnull CDVInvokedUrlCommand*)command;
- (void)checkSignInStatusCordova:(nonnull CDVInvokedUrlCommand*)command;
- (void)signOutCordova:(nonnull CDVInvokedUrlCommand*)command;

@end

#endif /* TableauOAuthCordova_h */
