angular.module('TableauSampleApp.directives', [])

// TS: Directive containing HTML and logic for the tab content when the user is not signed in.
.directive('signInPrompt', function() {
    return {
        // TS: An HTML element applies this directive when sign-in-prompt is an attribute.
        restrict: 'E',
        // TS: The HTML for the content that displays when the user is not signed in can
        // be edited in templates/sign-in-prompt.html.
        templateUrl: "templates/sign-in-prompt.html",
        replace: true,
        scope: {},
        controller: function($scope) {
            // TS: This directive is just a prompt to indicate that the user needs to sign in.
            // Sign in logic could easily be moved here instead of the controller for the header.
        }
    };
})

// TS: Directive containing HTML and logic for the tab content when the user is signed in.
.directive('vizContainer', function() {
    return {
        // TS: An HTML element applies this directive when viz-container is an attribute.
        // On the same HTML element, specify the url for the viz as a seperate attribute in single quotes.
        // For example: 'http://tableau.example.com/vizSample'
        restrict: 'E',
        templateUrl: "templates/viz-container.html",
        replace: true,
        scope: {
            viz: '='
        },
        // TS: Transclude allows additional HTML to be added to the viz container such as buttons for the toolbar.
        transclude: true,
        link:function(scope, elem, attrs, ctrl, transclude) {
            var containerDiv = elem[0];
            var url = attrs.url;
           
            // TS: Configurations for the viz. Check out all the options for
            // configuration on the Tableau JavaScript API help page.
            var options = {
                hideToolbar: true,
                height: "96%",
                width: "100%",
                onFirstInteractive: function () {
                    // TS: Add JavaScript that should execute after the 
                    // Tableau JS API has loaded the viz.
                }
            };
            var viz = new tableau.Viz(containerDiv, url, options);
            // TS: Add the viz object to the scope so that other controllers can access it.
            scope.viz = viz;

            // TS: Set the toolbar color.
            elem[0].querySelector("div.buttons").style.backgroundColor = attrs.toolbarColor;
            elem[0].querySelector("button").style.color = attrs.buttonColor;
            elem[0].querySelector("button").style.borderColor = attrs.buttonColor;
        },
        controller: function($scope) {
            // TS: Add all universal toolbar button functionality here, but create 
            // a seperate controller to handle viz specific toolbar functionality.
            $scope.revert = function() {
                $scope.viz.revertAllAsync();
            };
        }
     };
});