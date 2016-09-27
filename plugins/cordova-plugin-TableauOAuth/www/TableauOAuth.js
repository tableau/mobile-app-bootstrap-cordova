var exec = require('cordova/exec');

module.exports = {
    requestOAuthTokens: function (serverUrl, success, error) {
        exec(success, error, "TableauOAuth", "requestOAuthTokensCordova", [serverUrl]);
    },
    checkSignInStatus: function(serverUrl, siteName, success, error) {
        exec(success, error, "TableauOAuth", "checkSignInStatusCordova", [serverUrl, siteName]);
    },
    signOut: function(serverUrl, error) {
        exec(null, error, "TableauOAuth", "signOutCordova", [serverUrl]);
    }
};