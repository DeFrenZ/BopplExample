//
//  BopplAccount.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplAccount.h"

#define IF_NIL_RETURN_NIL_AND_LOG(value) \
if (value == nil) { \
NSLog(@"A parameter is nil in %s.", __PRETTY_FUNCTION__); \
return nil; \
}

#define IF_EMPTY_STRING_RETURN_NIL_AND_LOG(value) \
if (![value isKindOfClass:[NSString class]]) { \
NSLog(@"A parameter is not an NSString in %s.", __PRETTY_FUNCTION__); \
return nil; \
} else if ([value isEqualToString:@""]) { \
NSLog(@"A parameter is an empty NSString in %s.", __PRETTY_FUNCTION__); \
return nil; \
}

#define SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(var, vartype, value) \
if (value == nil) { \
NSLog(@"Trying to set %s in %s but parameter is nil.", #var, __PRETTY_FUNCTION__); \
return nil; \
} else if (![value isKindOfClass:[vartype class]]) { \
NSLog(@"Trying to set %s as a %@ in %s but parameter is a %@.", #var, [vartype class], __PRETTY_FUNCTION__, [value class]); \
return nil; \
} else { \
var = value; \
}

#pragma mark -

@implementation BopplAccount

#pragma mark Initialization

- (instancetype)initWithUsername:(NSString *)username andPassword:(NSString *)password
{
	self = [super init];
	if (self) {
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_username, NSString, username)
		IF_EMPTY_STRING_RETURN_NIL_AND_LOG(_username)
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_password, NSString, password)
		IF_EMPTY_STRING_RETURN_NIL_AND_LOG(_password)
	}
	return self;
}

- (instancetype)initWithEncodedAuthorizationString:(NSString *)encodedAuthorizationString
{
	NSString *authorizationString = [[self class] decodedStringFromString:encodedAuthorizationString];
	if (authorizationString == nil) {
		NSLog(@"Trying to %s with nil %@ parameter.", __PRETTY_FUNCTION__, @"authorizationString");
		return nil;
	}
	
	NSString *username = [[self class] usernameFromAuthorizationString:authorizationString];
	NSString *password = [[self class] passwordFromAuthorizationString:authorizationString];
	return [self initWithUsername:username andPassword:password];
}

+ (instancetype)accountWithUsername:(NSString *)username andPassword:(NSString *)password
{
	return [[self alloc] initWithUsername:username andPassword:password];
}

+ (instancetype)accountWithEncodedAuthorizationString:(NSString *)encodedAuthorizationString
{
	return [[self alloc] initWithEncodedAuthorizationString:encodedAuthorizationString];
}

#pragma mark BopplAccount encoding

+ (NSString *)decodedStringFromString:(NSString *)encodedString
{
	if (encodedString == nil || [encodedString isEqualToString:@""]) {
		NSLog(@"Trying to decode nil string.");
		return nil;
	}
	
	NSData *stringData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
	NSString *decodedString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
	return decodedString;
}

+ (NSString *)encodedStringFromString:(NSString *)decodedString
{
	if (decodedString == nil) {
		NSLog(@"Trying to encode nil string.");
		return nil;
	}
	
	NSData *stringData = [decodedString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *encodedString = [stringData base64EncodedStringWithOptions:0];
	return encodedString;
}

+ (NSArray *)componentsOfAuthorizationString:(NSString *)authorizationString
{
	if (authorizationString == nil) {
		NSLog(@"Trying to retrieve components of nil authorizationString.");
		return nil;
	}
	
	NSArray *components = [authorizationString componentsSeparatedByString:@":"];
	if ([components count] != 2) {
		NSLog(@"authorizationString has more than 2 components.");
		return nil;
	}
	
	return components;
}

+ (NSString *)usernameFromAuthorizationString:(NSString *)authorizationString
{
	if (authorizationString == nil) {
		NSLog(@"Trying to retrieve username of nil authorizationString.");
		return nil;
	}
	
	NSArray *components = [[self class] componentsOfAuthorizationString:authorizationString];
	if (components == nil) {
		NSLog(@"Trying to get username from invalid authorizationString.");
		return nil;
	}
	
	return components[0];
}

+ (NSString *)passwordFromAuthorizationString:(NSString *)authorizationString
{
	if (authorizationString == nil) {
		NSLog(@"Trying to retrieve password of nil authorizationString.");
		return nil;
	}
	
	NSArray *components = [[self class] componentsOfAuthorizationString:authorizationString];
	if (components == nil) {
		NSLog(@"Trying to get password from invalid authorizationString.");
		return nil;
	}
	
	return components[1];
}

+ (NSString *)authorizationStringWithUsername:(NSString *)username andPassword:(NSString *)password
{
	if (username == nil || [username isEqualToString:@""] || password == nil || [password isEqualToString:@""]) {
		NSLog(@"Trying to compose an authorizationString with invalid parameters: username = %@; password = %@.", username, password);
		return nil;
	}
	return [NSString stringWithFormat:@"%@:%@", username, password];
}

#pragma mark Equality

- (BOOL)isEqualToAccount:(BopplAccount *)anAccount
{
	if (anAccount == nil) {
		return NO;
	}
	
	BOOL haveEqualUsernames = (self.username == nil && anAccount.username == nil) || [self.username isEqualToString:anAccount.username];
	BOOL haveEqualPasswords = (self.password == nil && anAccount.password == nil) || [self.password isEqualToString:anAccount.password];
	return haveEqualUsernames && haveEqualPasswords;
}

- (BOOL)isEqual:(id)object
{
	if (self == object) {
		return YES;
	}
	
	if (![object isKindOfClass:[BopplAccount class]]) {
		return NO;
	}
	
	return [self isEqualToAccount:(BopplAccount *)object];
}

- (NSUInteger)hash
{
#warning can be improved with bit rotation
	return [self.username hash] ^ [self.password hash];
}

#pragma mark BopplAccount

- (NSString *)authorizationString
{
	return [[self class] authorizationStringWithUsername:self.username andPassword:self.password];
}

- (NSString *)encodedAuthorizationString
{
	NSString *authorizationString = [self authorizationString];
	if (authorizationString == nil) {
		NSLog(@"Trying to retrieve encodedAuthorizationString with invalid parameters.");
		return nil;
	}
	
	NSString *encodedAuthorizationString = [[self class] encodedStringFromString:authorizationString];
	return encodedAuthorizationString;
}

@end