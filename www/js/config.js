angular.module('TableauSampleApp.config', [])

/* TS: Edit these config variables to add your own vizzes. After adjusting these parameters, make sure to restart the simulator.
    demo      - Should ALWAYS be false once you have added your own config options.
    signInUrl - The url for the sign in page of the server that contains the vizzes. You may need to include an external redirect
                parameter in the URL if the InAppBrowser is not closing automatically after sign-in. For example, append
                'signin?externalRedirect=%2Fprojects' to the end of the server url.
    serverUrl - The url for the server that contains the vizzes, make sure to include the scheme.
    sitePath  - The site as it appears in the url (i.e. the name that follows site/ ) If there is no site path, use an empty string.
    oauth     - True will use oauth tokens for long term device sign in if they are enabled on the server, false will not use oauth tokens.
    viz#Url   - The full url for the viz. All the vizzes should be from the same server and site. Due to clickjacking protection
                the urls may need to be editted slightly following these guidelines: http://kb.tableau.com/articles/knowledgebase/embed-views-clickjack-protection
*/

.constant('config', {
    demo: true,
    signInUrl: "https://public.tableau.com",
    serverUrl: "https://public.tableau.com",
    sitePath: "",
    oauth: false,
    viz1Url: 'https://public.tableau.com/views/10_0InternationalTourism/InternationalTourism?:tooltip=n&:toolbar=top&:app=yes',
    viz2Url: 'https://public.tableau.com/views/10_0ClinicAnalytics/ClinicAnalytics?:tooltip=n&:toolbar=top',
    viz3Url: 'https://public.tableau.com/views/10_0SuperstoreSales/Overview?:tooltip=n&:toolbar=top'
})

/* Config Example 
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
*/ 


