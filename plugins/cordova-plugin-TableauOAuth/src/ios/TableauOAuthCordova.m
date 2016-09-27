#import "TableauOAuthCordova.h"

@implementation TableauOAuthCordova

TableauOAuth *_auth;

/**
 CORDOVA SPECIFIC: After initial sign in, request OAuth tokens from the server.
 */
- (void)requestOAuthTokensCordova:(nonnull CDVInvokedUrlCommand*)command
{
    if(command.arguments == nil) {
        // Check that the JavaScript interface did pass some arguments.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No arguments passed from JavaScript interface."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else if ([command.arguments count] != 1) {
        // Check for the proper number of arguments from the JavaScript interface.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Incorrect number of arguments."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        // Get argument information from JavaScript interface.
        // If string passed is not a valid url, serverUrl will be initialized as nil.
        NSURL *serverUrl = [NSURL URLWithString:[command.arguments objectAtIndex:0]];
        if(_auth == nil) {
            _auth = [[TableauOAuth alloc] init];
        }
        [_auth requestOAuthTokens:serverUrl];
    }
}

/**
 CORDOVA SPECIFIC: Check whether or not the user is signed in.
 */
- (void)checkSignInStatusCordova:(nonnull CDVInvokedUrlCommand*)command
{
    if(command.arguments == nil) {
        // Check that the JavaScript interface did pass some arguments.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No arguments passed from JavaScript interface."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else if ([command.arguments count] != 2) {
        // Check for the proper number of arguments from the JavaScript interface.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Incorrect number of arguments."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        // Get argument information from JavaScript interface.
        NSURL *serverUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:0]]];
        NSString *siteName = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:1]];
        
        if(_auth == nil) {
            _auth = [[TableauOAuth alloc] init];
        }
        [_auth checkSignInStatus:serverUrl forSite:siteName
                 successCallback:^{
                     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                 }
                 failureCallback:^{
                     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User is not signed in"];
                     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                 }
         ];
    }
}

/**
 CORDOVA SPECIFIC: Sign out the user.
 */
- (void)signOutCordova:(nonnull CDVInvokedUrlCommand*)command
{
    if(command.arguments == nil) {
        // Check that the JavaScript interface did pass some arguments.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No arguments passed from JavaScript interface."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else if ([command.arguments count] != 1) {
        // Check for the proper number of arguments from the JavaScript interface.
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Incorrect number of arguments."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        // Get argument information from JavaScript interface.
        NSURL *serverUrl = [NSURL URLWithString:[command.arguments objectAtIndex:0]];
        if(_auth == nil) {
            _auth = [[TableauOAuth alloc] init];
        }
        [_auth signOut:serverUrl];
    }
}

@end