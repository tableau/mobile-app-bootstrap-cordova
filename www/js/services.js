angular.module('TableauSampleApp.services', [])

// TS: This service handles the messaging related to sign in status
// so that controllers can communicate.
.factory('SignInStatusMessages', function($rootScope) {
    var SignInStatusMessages = {};
    // TS: The authentication controller broadcasts this message to
    // any controller that contains Tableau content after sign in is completed.
    // This message indicates to the controllers that content should be displayed.
    SignInStatusMessages.createViz = function() {
        $rootScope.$broadcast('createViz');
    };

    // TS: The authentication controller broadcasts this message to
    // any controller that contains Tableau content after the user signs out.
    // This message indicates to the controllers that content should be removed.
    SignInStatusMessages.removeViz = function() {
        $rootScope.$broadcast('removeViz');
    };

    // TS: Controllers that detect the user is not signed in should broadcast
    // this message to the authentication controller. In response to this 
    // message, the authentication controller should show the sign in button.
    SignInStatusMessages.sessionExpired = function() {
        $rootScope.$broadcast('sessionExpired');
    };

    // TS: Controllers that detect the user is signed in broadcast
    // this message to the authentication controller. In response to this 
    // message, the authentication controller shows the sign out button.
    SignInStatusMessages.sessionActive = function() {
        $rootScope.$broadcast('sessionActive');
    };

    return SignInStatusMessages;
})

// TS: This service acts as a wrapper around the Tableau OAuth Cordova plugin,
// so that it can be used in the standard Ionic way.
.factory('TableauAuth', ['$q', 'config', function($q, config) {
    return {
        // TS: Returns a promise that contains the sign in status.
        // True if the user is signed in.
        // False if the user is not signed in.
        checkSignInStatus : function() {
            // TS: Although the plugin uses a success and callback function,
            // wrap these in a promise that the service returns.
            // Angular JS expects promises rather than callback functions.
            var q = $q.defer();
            TableauOAuth.checkSignInStatus(config.serverUrl, config.sitePath,
            function(){
                // TS: User is signed in callback.
                q.resolve();
            },
            function() {
                // TS: User is not signed in callback.
                q.reject();
            });

            return q.promise;
        },
        // TS: Sign the user out.
        signOut : function() {
            TableauOAuth.signOut(config.serverUrl);
        },
        // TS: Request the initial set of OAuth tokens.
        requestOAuthTokens : function() {
            TableauOAuth.requestOAuthTokens(config.serverUrl);
        }
    };
}])