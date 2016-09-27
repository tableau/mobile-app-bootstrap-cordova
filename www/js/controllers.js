angular.module('TableauSampleApp.controllers', ['ngCordova'])

// TS: Controller for the home page of the app.
.controller('HomeCtrl', function($scope, $ionicPlatform, $cordovaInAppBrowser, $cordovaDevice, SignInStatusMessages, TableauAuth) { 
    // TS: On app start, broadcast message about the sign in status to auth controller.
    var start = true;
    $ionicPlatform.ready(function() {
        start = false;
        TableauAuth.checkSignInStatus()
            .then(function() {
                SignInStatusMessages.sessionActive();
            }, function() {
                SignInStatusMessages.sessionExpired();
            });
    });

    $scope.$on('$ionicView.enter', function() {
        if(!start) {
            TableauAuth.checkSignInStatus()
            .then(function() {
                $scope.hideViz = false;
            }, function() {
                $scope.hideViz = true;
                SignInStatusMessages.sessionExpired();
            });
        }
    });


    // TS: On tile click, open link in system browser.
    $scope.openLink = function(url) {
        var options = { 
            location: 'no',
            toolbar: 'no'
        };
        $cordovaInAppBrowser.open(url, '_system', options);
        
    }
})

// TS: Controller handles the sign in process by opening the InAppBrowser.
.controller('AuthCtrl', function($scope, $cordovaInAppBrowser, SignInStatusMessages, $rootScope, TableauAuth, config) {
    // TS: Received message that session is expired, show sign in button.
    $scope.$on('sessionExpired', function() {
        $scope.hideViz = true;
    });

    // TS: Received message that session is active, show sign out button.
    $scope.$on('sessionActive', function() {
        $scope.hideViz = false;
    });

    // TS: User clicked sign out button.
    $scope.signOut = function() {
        TableauAuth.signOut();
        SignInStatusMessages.removeViz();
        $scope.hideViz = true;
    };

    // TS: User clicked sign in button, open the InAppBrowser to handle sign in
    $scope.signIn = function() {
        var options = {
            location: 'no',
            toolbar: 'yes',
            enableViewportScale: 'yes',
            suppressesIncrementalRendering: 'yes'
        };
        
        // TS: Open the InAppBrowser to handle sign in.
        $cordovaInAppBrowser.open(config.signInUrl, '_blank', options);

        $rootScope.$on('$cordovaInAppBrowser:loaderror', function(e, event){
            console.log("loaderror", event.message);
        });

        $rootScope.$on('$cordovaInAppBrowser:exit', function(e, event){
            // TS: When the browser closes, check whether the user is signed in.
            // If the user is signed in, ask for the oauth tokens. If the user is 
            // NOT signed in, do nothing.
            TableauAuth.checkSignInStatus()
            .then(function() {
                if(config.oauth) {
                    TableauAuth.requestOAuthTokens();
                }
                SignInStatusMessages.createViz();
                $scope.hideViz = false;
            }, null);

        });
    }
})

// TS: Controller determines what content to display in the tab based on
// the sign in status of the user.
.controller('VizCtrl', function($scope, TableauAuth, $state, hideViz, SignInStatusMessages, $stateParams, config) {
    if(!config.demo) {
        // TS: hideViz is true if the user is signed in and false if the user is not signed in.
        // The value of hideViz is determined immediately when the state loads as part of the
        // resolve function for this state (see app.js)
        $scope.hideViz = hideViz;

        // TS: Everytime the user enters the view, check sign in status.
        $scope.$on('$ionicView.enter', function() {
            TableauAuth.checkSignInStatus()
                .then(function() {
                    $scope.hideViz = false;
                }, function() {
                    $scope.hideViz = true;
                    SignInStatusMessages.sessionExpired();
                });
        });

        // TS: Display the viz div after user signed in.
        $scope.$on('createViz', function() {
            // TS: Only update the view if this tab is the current tab.
            // This avoids loading several vizzes at the same time.
            if($state.$current.name == $stateParams.stateName) {
                $scope.hideViz = false;
            }
        });

        // TS: Display the sign in prompt after the user signed out.
        $scope.$on('removeViz', function() {
            // TS: Only update the view if this tab is the current tab.
            // This avoids loading several vizzes at the same time.
            if($state.$current.name == $stateParams.stateName) {
                $scope.hideViz = true;
            }
        });
    }
})

// TS: Controller for the date picker popup that filters the viz.
// This controller is used for the calendar filter popup in tab-3.html
.controller('calendar', function($scope, $ionicPopup) {
    // TS: Date button clicked, display date picking pop up.
    $scope.showPopup = function() {
        $scope.date = {};

        // TS: Load the popup as a directive.
        var myPopup = $ionicPopup.show({
            templateUrl: 'templates/calender-filter.html',
            title: 'Enter Date Range',
            scope: $scope,
            buttons: [
            { text: 'Cancel' },
            {
                text: '<b>Apply</b>',
                type: 'button-positive',
                onTap: function(e) {
                    if (!$scope.date.start || !$scope.date.end || $scope.date.start > $scope.date.end) {
                        // TS: User must complete two tasks before applying the date range:
                        // 1) selected two dates
                        // 2) end date is after start date
                        e.preventDefault();
                    } else {
                        return $scope.date;
                    }
                }
            }
            ]
        });

        // TS: After the date has been completed, apply the filter to the viz
        // using the Tableau JavaScript API.
        myPopup.then(function(date) {
            // TS: Date will be undefined if user canceled the popup.
            if(date) {
                var dashboard = $scope.viz.getWorkbook().getActiveSheet();
                var sheets = dashboard.getWorksheets();
                angular.forEach(sheets, function (sheet) {
                    sheet.applyRangeFilterAsync("Date", {
                        min: new Date(date.start),
                        max: new Date(date.end)
                    });
                });
            }
        });
    };
})

