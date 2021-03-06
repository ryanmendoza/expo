// Copyright 2018-present 650 Industries. All rights reserved.

#import <ABI38_0_0EXGoogleSignIn/ABI38_0_0EXGoogleSignIn+Serialization.h>
#import <ABI38_0_0UMCore/ABI38_0_0UMUtilities.h>

@implementation ABI38_0_0EXGoogleSignIn (Serialization)

+ (NSDictionary *)jsonFromGIDSignIn:(GIDSignIn *)input
{
  if (!input) return nil;
  
  return @{
           @"scopes": ABI38_0_0UMNullIfNil([input scopes]),
           @"language": ABI38_0_0UMNullIfNil([input language]),
           @"openIdRealm": ABI38_0_0UMNullIfNil([input openIDRealm]),
           @"accountName": ABI38_0_0UMNullIfNil([input loginHint]),
           @"hostedDomain": ABI38_0_0UMNullIfNil([input hostedDomain]),
           @"webClientId": ABI38_0_0UMNullIfNil([input serverClientID]),
           @"shouldFetchBasicProfile": ABI38_0_0UMNullIfNil(@([input shouldFetchBasicProfile])),
           @"currentUser": ABI38_0_0UMNullIfNil([ABI38_0_0EXGoogleSignIn jsonFromGIDGoogleUser:input.currentUser]),
           @"hasAuthInKeychain": ABI38_0_0UMNullIfNil(@([input hasPreviousSignIn]))
           };
}

+ (NSDictionary *)jsonFromGIDGoogleUser:(GIDGoogleUser *)input
{
  if (!input) return nil;
  
  NSMutableDictionary *output = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                  @"uid": ABI38_0_0UMNullIfNil([input userID]),
                                                                                  @"auth": ABI38_0_0UMNullIfNil([ABI38_0_0EXGoogleSignIn jsonFromGIDAuthentication:[input authentication]]),
                                                                                  @"scopes": ABI38_0_0UMNullIfNil([input grantedScopes]),
                                                                                  @"domain": ABI38_0_0UMNullIfNil([input hostedDomain]),
                                                                                  @"serverAuthCode": ABI38_0_0UMNullIfNil([input serverAuthCode]),
                                                                                  }];
  
  
  NSDictionary *profileData = [ABI38_0_0EXGoogleSignIn jsonFromGIDProfileData:[input profile]];
  if (profileData != nil) {
    [output addEntriesFromDictionary:profileData];
  }

  return output;
}

+ (NSNumber *)jsonFromNSDate:(NSDate *)input
{
  if (!input) return nil;
  return [NSNumber numberWithDouble:input.timeIntervalSinceNow];
}

+ (NSDictionary *)jsonFromGIDAuthentication:(GIDAuthentication *)input
{
  if (!input) return nil;
  return @{
           @"clientId": ABI38_0_0UMNullIfNil([input clientID]),
           @"accessToken": ABI38_0_0UMNullIfNil([input accessToken]),
           @"accessTokenExpirationDate": ABI38_0_0UMNullIfNil([ABI38_0_0EXGoogleSignIn jsonFromNSDate:[input accessTokenExpirationDate]]),
           @"refreshToken": ABI38_0_0UMNullIfNil([input refreshToken]),
           @"idToken": ABI38_0_0UMNullIfNil([input idToken]),
           @"idTokenExpirationDate": ABI38_0_0UMNullIfNil([ABI38_0_0EXGoogleSignIn jsonFromNSDate:[input idTokenExpirationDate]])
           };
}

+ (NSDictionary *)jsonFromGIDProfileData:(GIDProfileData *)input
{
  if (!input) return nil;
  NSMutableDictionary *output =
  [NSMutableDictionary dictionaryWithDictionary:@{
                                                  @"email": ABI38_0_0UMNullIfNil([input email]),
                                                  @"displayName": ABI38_0_0UMNullIfNil([input name]),
                                                  @"firstName": ABI38_0_0UMNullIfNil([input givenName]),
                                                  @"lastName": ABI38_0_0UMNullIfNil([input familyName]),
                                                  }];
  if (input.hasImage) {
    NSURL *imageURL = [input imageURLWithDimension:128];
    if (imageURL) [output setValue:[imageURL absoluteString] forKey:@"photoURL"];
  }
  return output;
}

+ (NSString *)jsonFromGIDSignInErrorCode:(GIDSignInErrorCode)input
{
  switch (input) {
    case kGIDSignInErrorCodeKeychain:
      return @"A problem reading or writing to the application keychain.";
    case kGIDSignInErrorCodeHasNoAuthInKeychain:
      return @"There are no auth tokens in the keychain. This error code will be returned by signInSilently if the user has never signed in before with the given scopes, or if they have since signed out.";
    case kGIDSignInErrorCodeCanceled:
      return @"The user canceled the sign in request.";
    case kGIDSignInErrorCodeEMM:
      return @"An Enterprise Mobility Management related error has occurred.";
    case kGIDSignInErrorCodeUnknown:
    default:
      return @"kGIDSignInErrorCodeUnknown: An unknown error has occurred.";
  }
}
@end
