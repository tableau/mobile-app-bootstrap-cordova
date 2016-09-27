<h1>Tableau OAuth Plugin:</h1>
<ol>
    <li> check if user is authenticated</li>
    <li> manage oauth tokens for a session</li>
    <li> sign out the user</li>
</ol>

<p> Tasks are implemented in src/ios/TableauOauth.m </p>
<p> Results from tasks are communicated back to a JavaScript layer via www/TableauOAuth.js </p>


<h2> Check Login Flow: </h2>
<pre>
                     checkSignInStatus
                            |
                  Is the session expired?
                            |
                __________________________
                |                           |
               NO                          YES
            User is signed in.              |
                                    Does the app have tokens?
                                            |
                                __________________________
                                |                         |
                               YES                        NO
                                |                   User is NOT signed in.     
                        Can they be refreshed?
                                |
                        ___________________
                       |                   |
                      YES                  NO
                User is signed in.      User is NOT signed in.
                    
</pre>

<h2> OAuth tokens: </h2>
<ul>
    <li>Get intial access/refresh tokens</li>
    <li>Store in keychain</li>
    <li>Refresh access token if expired</li>
    <li>Revoke refresh and access token on sign out </li>
</ul>

<h3>Security:</h3>
<ul>
    <li>
    Stores access and refresh tokens in Keychain
        <ul>
            <li> TableauOAuth.m: (void )addTokenToKeychain:(NSString *)tokenValue forIdentifier:(tokenName) tokenName </li>
        </ul>
    </li>
    <li>
    Deletes tokens from keychain after sign out
        <ul>
            <li> TableauOAuth.m: (void) deleteTokenFromKeychain:(tokenName) tokenName </li>
        </ul>
    </li>
    <li>
    Sends tokens to server as cookies
        <ul>
            <li> TableauOAuth.m: (void) addCookie:(NSString *)cookieValue forIdentifier:(NSString *)cookieName forDuration:(NSTimeInterval) duration </li>
        </ul>
    </li>
    <li>
    Settings for keychain items
        <ul>
            <li> TableauOAuth.m: (NSMutableDictionary *) createKeychainItem:(tokenName) tokenName </li>
            <li> Note: no specified kSecAttrAccessGroup means keychain item cannot be accessed by other apps </li>
        </ul>
    </li>
</ul>
