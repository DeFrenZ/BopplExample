//
//  BopplAccountTest.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BasicHTTPAuthAccount.h"

@interface BasicHTTPAuthAccountTest : XCTestCase

@property (strong, nonatomic) BasicHTTPAuthAccount *exampleAccount;
@property (strong, nonatomic) BasicHTTPAuthAccount *exampleInvalidAccount;
@property (strong, nonatomic) NSString *exampleInvalidAccountEncodedAuthorizationString;

@end

@implementation BasicHTTPAuthAccountTest

#pragma mark XCTestCase

- (void)setUp
{
	[super setUp];
	self.exampleAccount = [BasicHTTPAuthAccount accountWithUsername:@"defrenz@gmail.com" andPassword:@"password123"];
	self.exampleInvalidAccount = [BasicHTTPAuthAccount accountWithUsername:@"test@example.com" andPassword:@"password"];
	self.exampleInvalidAccountEncodedAuthorizationString = @"dGVzdEBleGFtcGxlLmNvbTpwYXNzd29yZA==";
}

#pragma mark BopplAccountTest

- (void)testAccountWithValidCredentials
{
	BasicHTTPAuthAccount *testAccount;
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:self.exampleInvalidAccount.username andPassword:self.exampleInvalidAccount.password];
	XCTAssertNotNil(testAccount, @"Should have returned a not nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithEncodedAuthorizationString:self.exampleInvalidAccountEncodedAuthorizationString];
	XCTAssertNotNil(testAccount, @"Should have returned a not nil BopplAccount.");
}

- (void)testAccountWithInvalidCredentials
{
	BasicHTTPAuthAccount *testAccount;
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:nil andPassword:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:nil andPassword:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:@"" andPassword:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:@"" andPassword:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:self.exampleInvalidAccount.username andPassword:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:self.exampleInvalidAccount.username andPassword:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:nil andPassword:self.exampleInvalidAccount.password];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithUsername:@"" andPassword:self.exampleInvalidAccount.password];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithEncodedAuthorizationString:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BasicHTTPAuthAccount accountWithEncodedAuthorizationString:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
}

- (void)testBase64ValidEncodingAndDecoding
{
	NSString *encodedString = [self.exampleInvalidAccount encodedAuthorizationString];
	XCTAssertNotNil(encodedString, @"Should have returned a not nil encodedString.");
	XCTAssertEqualObjects(encodedString, self.exampleInvalidAccountEncodedAuthorizationString, @"The encoded string should be equal to the precomputed one.");
	BasicHTTPAuthAccount *testAccount = [BasicHTTPAuthAccount accountWithEncodedAuthorizationString:encodedString];
	XCTAssertEqualObjects(testAccount, self.exampleInvalidAccount, @"The reconstructed account should be equal to the starting one.");
}

- (void)testBase64InvalidEncodingAndDecoding
{
	NSString *encodedString = [self.exampleAccount encodedAuthorizationString];
	XCTAssertNotEqualObjects(encodedString, self.exampleInvalidAccountEncodedAuthorizationString, @"The encoded string should be different from the precomputed one.");
	BasicHTTPAuthAccount *testAccount = [BasicHTTPAuthAccount accountWithEncodedAuthorizationString:encodedString];
	XCTAssertNotEqualObjects(testAccount, self.exampleInvalidAccount, @"The reconstructed account should be different from the starting one.");
}

@end
