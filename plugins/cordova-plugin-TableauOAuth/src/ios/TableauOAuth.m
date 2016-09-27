/********* TableauOAuth.m Cordova Plugin Implementation *******/

#import "TableauOAuth.h"

@implementation TableauOAuth

NSURLConnection *tokenConnection;
NSURLConnection  *signInStatusConnection;
NSURLConnection  *revokeConnection;
NSMutableData *_tokenResponseData;
NSMutableData *_signInStatusResponseData;
void (^successBlock)(void);
void (^failureBlock)(void);
NSURL *server;
NSString *site;

// Token names
typedef enum {
    accessToken,
    refreshToken,
    xsrfToken
} tokenName;

// Usage example: NSString *accessTokenString = tokenNameString(accessToken)
#define tokenNameString(enum) [@[@"access_token",@"refresh_token",@"xsrf_token"] objectAtIndex:enum]

// Cookie names
typedef enum {
    accessCookie,
    xsrfCookie,
    workgroupCookie
} cookieName;

#define cookieNameString(enum) [@[@"tableau_access_token",@"XSRF-TOKEN",@"workgroup_session_id"] objectAtIndex:enum]

// Header names
typedef enum {
    xsrfHeader
} headerName;

#define headerNameString(enum) [@[@"X-XSRF-TOKEN"] objectAtIndex:enum]

static NSString *service = @"Tableau.OAuth";

/**
 Send request to Tableau Server to get initial OAuth access and request token.
 This method should only be called after a successful sign-in to ensure that the 
 wg-session cookie is still valid.
 @param serverURL
 The name of the server. Should include http:// or https://
 ex: http://tableau.example.com
 */
- (void)requestOAuthTokens: (nonnull NSURL *) serverUrl {
    server = serverUrl;
    
    // Get the wg_session_id cookie.
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *sessionCookie;
    for (cookie in [storage cookies])
    {
        if ([cookie.name isEqualToString:cookieNameString(workgroupCookie)]) {
            sessionCookie = cookie;
            break;
        }
    }
    NSString *sessionCookieValue = @"";
    if (sessionCookie != nil) {
        sessionCookieValue = [NSString stringWithFormat:@"%@", sessionCookie.value];
    }
    
    // Make POST request to get access token.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/v1/token", server]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    // Get the UDID vendor identifier. This UDID is only accessible for apps that come
    // from the same vendor on the same device. It is guaranteed to be unique for the device
    // and remains constant unless the user deletes or reinstalls the app.
    // Only one valid set of access and refresh tokens are issued per UDID.
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // The device name is used to identify the device on the vizportal settings UI, so that a Tableau server
    // admin can delete a device and revoke its tokens.
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *urlEncodedDeviceName = [deviceName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    urlEncodedDeviceName = [urlEncodedDeviceName stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    // Set the data for the body of the request.
    NSString *data = [NSString stringWithFormat: @"grant_type=session&client_id=%@&session_id=%@&device_id=%@&device_name=%@", deviceId, sessionCookieValue, deviceId, urlEncodedDeviceName];
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody: requestData];
    
    // Set the headers for the request.
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    
    // Initialize and send the request.
    tokenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 Get new access token from the server after it has expired
 @remark Assumes that access token and refresh token are present in the iOS Keychain
 */
- (void) refreshAccessToken {
    // Make POST request to get a refreshed access token.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/v1/token", server]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    // Get the refresh token value from the iOS Keychain and url encode it.
    NSString *refreshTokenValue = [self getTokenFromKeychain:refreshToken];
    NSString *urlEncodedToken =  [refreshTokenValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    urlEncodedToken = [urlEncodedToken stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    // Set the data for the body of the request.
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *data = [NSString stringWithFormat: @"client_id=%@&device_id=%@&grant_type=refresh_token&refresh_token=%@&site_namespace=%@", deviceId, deviceId, urlEncodedToken, site];
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody: requestData];
    
    // Set the headers and body for the request.
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    
    // Initialize and send the request.
    tokenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 Send request to server to revoke the tokens to log out user
 @param tokenName
 The name of the token
 */
- (void) revokeToken: (tokenName) tokenName {
    // Make POST request to revoke token.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/v1/revoke", server]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    // Get the value of the token from the iOS Keychain and url encode it.
    NSString *tokenValue = [self getTokenFromKeychain:tokenName];
    NSString *urlEncodedToken =  [tokenValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    urlEncodedToken = [urlEncodedToken stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    // Set the data for the body of the request.
    NSString *data = [NSString stringWithFormat: @"token=%@&token_hint=%@", urlEncodedToken, tokenNameString(tokenName)];
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody: requestData];
    
    // Set headers for the request.
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    
    // Initialize and send the request.
    revokeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 Send request to server to check sign in status.
 @param serverUrl
 The name of the server. Should include http:// or https://
 ex: http://tableau.example.com
 @param siteName
 The name of the site that is displayed in the site url.
 @param successCallbackBlock
 Block containing code to execute if user is signed in.
 @param failureCallbackBlock
 Block containing code to execute if user is NOT signed in.
 */
- (void)checkSignInStatus: (nonnull NSURL *) serverUrl forSite:(nonnull NSString *) siteName successCallback:(nullable void (^)(void))successCallbackBlock failureCallback:(nullable void (^)(void))failureCallbackBlock {
    site = siteName;
    server = serverUrl;
    successBlock = successCallbackBlock;
    failureBlock = failureCallbackBlock;
    
    // Get the xsrf-token cookie.
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *xsrfTokenCookie;
    for (cookie in [storage cookies])
    {
        if ([cookie.name isEqualToString:cookieNameString(xsrfCookie)]) {
            xsrfTokenCookie = cookie;
            break;
        }
    }
    
    // Make POST request for the session info to check sign in status.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/vizportal/api/web/v1/getSessionInfo", server]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    // Set the data for the body of the request.
    NSString *data = [NSString stringWithFormat: @"{\"method\":\"getSessionInfo\",\"params\":{}}"];
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody: requestData];
    
    // Add request headers and body.
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    // If xsrf-token cookie exists, include it in the header.
    if(xsrfTokenCookie != nil) {
        [request setValue:[xsrfTokenCookie value] forHTTPHeaderField:headerNameString(xsrfHeader)];
    }
    
    // Initialize and send the request.
    signInStatusConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 Sign out by deleting cookies and OAuth tokens if they exist.
 @param serverUrl
 The name of the server. Should include http:// or https://
 ex: http://tableau.example.com
 */
- (void)signOut: (nonnull NSURL *) serverUrl {
    server = serverUrl;
    
    // If app has tokens, send message to server to revoke them.
    if([self getTokenFromKeychain:accessToken] != nil && [self getTokenFromKeychain:refreshToken] != nil) {
        [self revokeToken:accessToken];
        [self revokeToken:refreshToken];
    }
    
    // Delete the cookies.
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    // Delete OAuth tokens from the iOS Keychain.
    [self deleteTokenFromKeychain:accessToken];
    [self deleteTokenFromKeychain:refreshToken];
    [self deleteTokenFromKeychain:xsrfToken];
}

#pragma mark iOS Keychain Methods

/**
 Creates an iOS Keychain item for a token. The iOS Keychain item keeps formatting consistent
 for the dictionary used to get, update, add, and delete the item from iOS Keychain.
 @param tokenName
 The name of the token
 */
- (NSMutableDictionary *) createKeychainItem:(tokenName) tokenName {
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    
    // Specify what type of iOS Keychain item to use. In this case, use kSecClassGenericPassword
    // to store token and value pair.
    [keychainItem setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // Use the name of the token as the identifier for the token.
    NSData *encodedIdentifier = [tokenNameString(tokenName) dataUsingEncoding:NSUTF8StringEncoding];
    [keychainItem setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [keychainItem setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    // The service specifies what the tokens are used for. In this case, the tokens are
    // use to in the Tableau OAuth process.
    [keychainItem setObject:service forKey:(id)kSecAttrService];
    [keychainItem setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    
    return keychainItem;
}

/**
 Add token to the iOS Keychain.
 Update token's value if it already exists in the iOS Keychain.
 @param tokenValue
 The value of the token
 @param tokenName
 The name of the token
 */
- (void) addTokenToKeychain:(NSString *)tokenValue forIdentifier:(tokenName) tokenName {
    NSMutableDictionary *keychainItem = [self createKeychainItem:tokenName];
    
    // Check if the iOS Keychain item already exists before adding it.
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr) {
        // If item already exists, update it instead.
        [self updateTokenInKeychain:tokenValue forIdentifier:tokenName];
    } else {
        // Add item to the iOS Keychain.
        [keychainItem setObject:[tokenValue dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
    }
}

/**
 Update token in the iOS Keychain
 @param tokenValue
 The value of the token
 @param tokenName
 The name of the token
 */
- (void) updateTokenInKeychain:(NSString *)tokenValue forIdentifier:(tokenName) tokenName {
    NSMutableDictionary *keychainItem = [self createKeychainItem:tokenName];
    
    // Only update iOS Keychain item if it already exists in the iOS Keychain.
    if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr) {
        NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
        [attributesToUpdate setObject:[tokenValue dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        
        OSStatus sts = SecItemUpdate((__bridge CFDictionaryRef)keychainItem, (__bridge CFDictionaryRef)attributesToUpdate);
    }
}

/**
 Get token from the iOS Keychain
 @param tokenName
 The name of the token
 @return value of token if it exists in the iOS Keychain, otherwise returns nil
 */
- (NSString *) getTokenFromKeychain:(tokenName) tokenName {
    NSMutableDictionary *keychainItem = [self createKeychainItem:tokenName];
    
    // Set extra attribute for searching for matches in the iOS Keychain.
    [keychainItem setObject:(__bridge id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainItem setObject:(__bridge id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    
    // Look for a match to the search dictionary in the iOS Keychain.
    CFDictionaryRef result = nil;
    OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    
    // Check if item exists.
    if (sts == noErr) {
        NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
        NSData *tokenValue = resultDict[(__bridge id)kSecValueData];
        return [[NSString alloc] initWithData:tokenValue encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

/**
 Delete token from the iOS Keychain
 @param tokenName
 The name of the token
 */
- (void) deleteTokenFromKeychain:(tokenName) tokenName {
    NSMutableDictionary *keychainItem = [self createKeychainItem:tokenName];
    
    // Check if the iOS Keychain item exists before deleting it.
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr) {
        OSStatus sts = SecItemDelete((__bridge CFDictionaryRef)keychainItem);
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Initialize the connection data.
    if(connection == tokenConnection) {
        _tokenResponseData = [[NSMutableData alloc] init];
    } else if(connection == signInStatusConnection) {
        _signInStatusResponseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the connection data.
    if(connection == tokenConnection) {
        [_tokenResponseData appendData:data];
    } else if(connection == signInStatusConnection) {
        [_signInStatusResponseData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil, no need to cache resposne.
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Parse resulting connection data.
    if(connection == tokenConnection) {
        NSNumber *tokenParseSuccess = [self parseTokensJSON:(NSData *)_tokenResponseData];
        [self executeSignInStatusResultCallback:tokenParseSuccess];
    } else if(connection == signInStatusConnection) {
        NSNumber *sessionParseSuccess = [self parseSessionJSON:_signInStatusResponseData];
        [self executeSignInStatusResultCallback:sessionParseSuccess];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}


/**
 Parse the JSON response from the request for OAuth tokens.
 If parse is successful, store tokens and values in the iOS Keychain and as cookies.
 @param tokenData
 Data containing the JSON token data.
 @return NSNumber with value of YES if the JSON contains tokens and these tokens are stored.
 NSNumber with value of NO if the JSON data contains an error.
 */
- (NSNumber *) parseTokensJSON: (NSData *) tokenData {
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:tokenData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *keys = [jsonData allKeys];
    if ([keys containsObject:@"error"]) {
        // Server revoked tokens for device so delete access/refresh tokens from the iOS Keychain.
        // User is no longer signed in.
        [self deleteTokenFromKeychain:accessToken];
        [self deleteTokenFromKeychain:xsrfToken];
        [self deleteTokenFromKeychain:refreshToken];
        return [NSNumber numberWithBool:NO];
    } else {
        // Parse tokens and add to the iOS Keychain and cookie storage.
        // Specify the maximum duration that a cookie can exist without been deleted or replaced.
        NSTimeInterval duration = 2629743;
        for (id key in keys) {
            NSDictionary *token = [jsonData objectForKey:key];
            NSString *keyAsString = [NSString stringWithFormat:@"%@", key];
            NSString *tokenAsString = [NSString stringWithFormat:@"%@", token];
            if ([keyAsString isEqual: tokenNameString(accessToken)]) {
                // Add the access token to the iOS Keychain and cookie storage.
                [self addTokenToKeychain:tokenAsString forIdentifier:accessToken];
                [self addCookie:[self getTokenFromKeychain:accessToken] forIdentifier:cookieNameString(accessCookie) forDuration:duration];
            } else if([keyAsString isEqual:tokenNameString(refreshToken)]) {
                // Add the refresh token to the iOS Keychain. It does not need to be added to the cookie storage.
                [self addTokenToKeychain:tokenAsString forIdentifier:refreshToken];
            } else if ([keyAsString isEqual:tokenNameString(xsrfToken)]) {
                // Add the xsrf token to the iOS Keychain and cookie storage.
                [self addTokenToKeychain:tokenAsString forIdentifier:xsrfToken];
                [self addCookie:[self getTokenFromKeychain:xsrfToken] forIdentifier:cookieNameString(xsrfCookie) forDuration:duration];
            }
        }
        return [NSNumber numberWithBool:YES];
    }
}

/**
 Add sessionless cookie to cookie storage for specified duration
 @param cookieValue
 The value of the cookie.
 @param cookieName
 The name of the cookie.
 @param duration
 The duration in seconds that the cookie will persist in storage.
 */
- (void) addCookie:(NSString *)cookieValue forIdentifier:(NSString *)cookieName forDuration:(NSTimeInterval) duration{
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    
    // Set the properties for the cookie.
    [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
    [cookieProperties setObject:cookieValue forKey:NSHTTPCookieValue];
    [cookieProperties setObject:server.host forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:server.host forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:duration] forKey:NSHTTPCookieExpires];
    
    // Add the cookie to the cookie storage.
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

/**
 Parse the JSON response from the sign in status check.
 @param sessionData
 Data containing the JSON session data.
 @return 
 NSNumber with value of YES if the JSON contains session info (indicates user is logged in).
 NSNumber with value of NO if the JSON data contains an error (indicates user is not logged in).
 Nil if the sign in status is being checked after refreshing the access token.
 */
- (NSNumber *) parseSessionJSON: (NSData *) sessionData {
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:sessionData options:NSJSONReadingMutableLeaves error:nil];
    
    // Check the JSON data to see if it contains error. If it contains errors, then the user is not signed in.
    NSDictionary *result = [jsonData objectForKey:@"result"];
    NSArray *keys = [result allKeys];
    if ([keys containsObject:@"errors"]) {
        // User may not be logged in.
        // If the iOS Keychain has an refresh token, try to get a new access token and
        // recheck whether or not the user is logged in.
        if([self getTokenFromKeychain:accessToken] != nil) {
            [self refreshAccessToken];
            return nil;
        } else {
            // If no refresh token is present, user is definitely not logged in.
            return [NSNumber numberWithBool:NO];
        }
    } else {
        // User is currently logged in.
        return [NSNumber numberWithBool:YES];
    }
}

/**
 Send response back to blocks about sign in status.
 @param success
 NSNumber YES for successful sign in status, NO for failed sign in status, nil for no response
 */
- (void) executeSignInStatusResultCallback:(NSNumber *) success {
    if (success != nil) {
        if(success == [NSNumber numberWithBool:YES] && successBlock != nil) {
            // Call the success block.
            successBlock();
        } else if (success == [NSNumber numberWithBool:NO] && failureBlock != nil){
            // Call the failure block.
            failureBlock();
        }
    }
}


@end
