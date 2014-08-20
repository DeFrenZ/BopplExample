//
//  BopplAccountTest.m
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BopplAccount.h"

@interface BopplAccountTest : XCTestCase

@property (strong, nonatomic) BopplAccount *exampleAccount;
@property (strong, nonatomic) BopplAccount *exampleInvalidAccount;
@property (strong, nonatomic) NSString *exampleInvalidAccountEncodedAuthorizationString;

@end

@implementation BopplAccountTest

#pragma mark XCTestCase

- (void)setUp
{
	[super setUp];
	self.exampleAccount = [BopplAccount accountWithUsername:@"defrenz@gmail.com" andPassword:@"password123"];
	self.exampleInvalidAccount = [BopplAccount accountWithUsername:@"test@example.com" andPassword:@"password"];
	self.exampleInvalidAccountEncodedAuthorizationString = @"dGVzdEBleGFtcGxlLmNvbTpwYXNzd29yZA==";
}

#pragma mark BopplAccountTest

- (void)testAccountWithValidCredentials
{
	BopplAccount *testAccount;
	
	testAccount = [BopplAccount accountWithUsername:self.exampleInvalidAccount.username andPassword:self.exampleInvalidAccount.password];
	XCTAssertNotNil(testAccount, @"Should have returned a not nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithEncodedAuthorizationString:self.exampleInvalidAccountEncodedAuthorizationString];
	XCTAssertNotNil(testAccount, @"Should have returned a not nil BopplAccount.");
}

- (void)testAccountWithInvalidCredentials
{
	BopplAccount *testAccount;
	
	testAccount = [BopplAccount accountWithUsername:nil andPassword:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:nil andPassword:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:@"" andPassword:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:@"" andPassword:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:self.exampleInvalidAccount.username andPassword:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:self.exampleInvalidAccount.username andPassword:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:nil andPassword:self.exampleInvalidAccount.password];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithUsername:@"" andPassword:self.exampleInvalidAccount.password];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithEncodedAuthorizationString:nil];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
	
	testAccount = [BopplAccount accountWithEncodedAuthorizationString:@""];
	XCTAssertNil(testAccount, @"Should have returned a nil BopplAccount.");
}

- (void)testBase64ValidEncodingAndDecoding
{
	NSString *encodedString = [self.exampleInvalidAccount encodedAuthorizationString];
	XCTAssertNotNil(encodedString, @"Should have returned a not nil encodedString.");
	XCTAssertEqualObjects(encodedString, self.exampleInvalidAccountEncodedAuthorizationString, @"The encoded string should be equal to the precomputed one.");
	BopplAccount *testAccount = [BopplAccount accountWithEncodedAuthorizationString:encodedString];
	XCTAssertEqualObjects(testAccount, self.exampleInvalidAccount, @"The reconstructed account should be equal to the starting one.");
}

- (void)testBase64InvalidEncodingAndDecoding
{
	NSString *encodedString = [self.exampleAccount encodedAuthorizationString];
	XCTAssertNotEqualObjects(encodedString, self.exampleInvalidAccountEncodedAuthorizationString, @"The encoded string should be different from the precomputed one.");
	BopplAccount *testAccount = [BopplAccount accountWithEncodedAuthorizationString:encodedString];
	XCTAssertNotEqualObjects(testAccount, self.exampleInvalidAccount, @"The reconstructed account should be different from the starting one.");
}

@end
