//
//  TableauOAuth.h
//

#ifndef TableauOAuth_h
#define TableauOAuth_h


@interface TableauOAuth : NSObject<NSURLConnectionDelegate>

/**
 Send request to Tableau Server to get initial OAuth access and request token.
 This method should only be called after a successful sign-in to ensure that the
 wg-session cookie is still valid.
 @param serverURL
 The name of the server. Should include http:// or https://
 ex: http://tableau.example.com
 */
- (void)requestOAuthTokens: (nonnull NSURL *) serverUrl;

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
- (void)checkSignInStatus: (nonnull NSURL *) serverUrl forSite:(nonnull NSString *) siteName successCallback:(nullable void (^)(void))successCallbackBlock failureCallback:(nullable void (^)(void))failureCallbackBlock;

/**
 Sign out by deleting cookies and OAuth tokens if they exist.
 @param serverUrl
 The name of the server. Should include http:// or https://
 ex: http://tableau.example.com
 */
- (void)signOut: (nonnull NSURL *) serverUrl;

@end

#endif /* TableauOAuth_h */
