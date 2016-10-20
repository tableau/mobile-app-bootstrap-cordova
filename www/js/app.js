// Tableau Custom Mobile App

// TS: If it's your first time looking at the Mobile App Bootstrap, this is a great place to start!

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'TableauSampleApp' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'TableauSampleApp.config' is found in config.js
// 'TableauSampleApp.services' is found in services.js
// 'TableauSampleApp.controllers' is found in controllers.js
// 'TableauSampleApp.directives' is found in directives.js
angular.module('TableauSampleApp', ['ionic','TableauSampleApp.config', 'TableauSampleApp.controllers', 'TableauSampleApp.services', 'TableauSampleApp.directives', 'ngCordova', 'ion-datetime-picker'])

.run(function($ionicPlatform, $state, $rootScope, config) {
  $rootScope.config = config;
  $ionicPlatform.ready(function() {
    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    if (window.cordova && window.cordova.plugins && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      cordova.plugins.Keyboard.disableScroll(true);

    }
    if (window.StatusBar) {
      // org.apache.cordova.statusbar required
      StatusBar.styleDefault();
    }
  });

  $ionicPlatform.on('resume', function(){
      // TS: Reload the current state when app is brought to foreground.
      $state.go($state.current, {}, {reload: true});
  });
})

.config(function($stateProvider, $urlRouterProvider) {
  // Ionic uses AngularUI Router which uses the concept of states
  // Learn more here: https://github.com/angular-ui/ui-router
  // Set up the various states which the app can be in.
  // Each state's controller can be found in controllers.js.
  $stateProvider

  // Setup an abstract state for the tabs directive.
  .state('tab', {
    url: '/tab',
    abstract: true,
    templateUrl: 'templates/tabs.html',
  })

  // Each tab has its own nav history stack:

  .state('tab.home', {
    url: '/home',
    views: {
      'tab-home': {
        templateUrl: 'templates/tab-home.html',
        controller: 'HomeCtrl'
      }
    }
  })

  .state('tab.viz1', {
    url: '/viz1',
    // TS: Set the state name as a parameter so that the controller
    // can access it.
    params: {
      stateName: 'tab.viz1'
    },
    views: {
      'tab-viz1': {
        templateUrl: 'templates/tab-viz1.html',
        controller: 'VizCtrl',
        resolve:{
          // TS: Before the state loads, wait for the request to determine the
          // sign in status of the user. The result is shared with the controller
          // using dependency injection of hideViz. hideViz is true if the
          // user is NOT signed in and false if the user is signed in.
          hideViz : function (TableauAuth) {
            return TableauAuth.checkSignInStatus()
              .then(function() {
                return false;
              }, function() {
                return true;
              });
          }
        }
      }
    }
  })

  .state('tab.viz2', {
    url: '/viz2',
    params: {
      stateName: 'tab.viz2'
    },
    views: {
      'tab-viz2': {
        templateUrl: 'templates/tab-viz2.html',
        controller: 'VizCtrl',
        resolve:{
          hideViz : function (TableauAuth) {
            return TableauAuth.checkSignInStatus()
              .then(function() {
                return false;
              }, function() {
                return true;
              });
          }
        }
      }
    }
  })

  .state('tab.viz3', {
    url: '/viz3',
    params: {
      stateName: 'tab.viz3'
    },
    views: {
      'tab-viz3': {
        templateUrl: 'templates/tab-viz3.html',
        controller: 'VizCtrl',
        resolve:{
          hideViz : function (TableauAuth) {
            return TableauAuth.checkSignInStatus()
              .then(function() {
                return false;
              }, function() {
                return true;
              });
          }
        }
      }
    }
  });

  // If none of the above states are matched, use this as the fallback.
  $urlRouterProvider.otherwise('/tab/home');

});
