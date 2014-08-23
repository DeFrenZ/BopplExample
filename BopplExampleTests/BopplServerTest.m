//
//  BopplServerTest.m
//  BopplExample
//
//  Created by Davide De Franceschi on 21/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BopplServer.h"

#define TEST_TIMEOUT_TIME_S 10.0
#define TEST_TIMEOUT_TIME_NS ((int64_t)(TEST_TIMEOUT_TIME_S * NSEC_PER_SEC))
#pragma mark -

@interface BopplServerTest : XCTestCase

@property (strong, nonatomic) BasicHTTPAuthAccount *exampleAccount;
@property (strong, nonatomic) BasicHTTPAuthAccount *exampleInvalidAccount;
@property (strong, nonatomic) BopplServer *exampleServer;

@end

@implementation BopplServerTest

#pragma mark XCTestCase

- (void)setUp
{
    [super setUp];
	self.exampleAccount = [BasicHTTPAuthAccount accountWithUsername:@"defrenz@gmail.com" andPassword:@"password123"];
	self.exampleInvalidAccount = [BasicHTTPAuthAccount accountWithUsername:@"test@example.com" andPassword:@"password"];
	self.exampleServer = [BopplFakeServer new];
	self.exampleServer.account = self.exampleAccount;
}

#pragma mark BopplServerTest

- (void)testAuthenticationWithValidAccount
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	[self.exampleServer authenticateAccountWithCompletion:^(BOOL authenticated, NSHTTPURLResponse *response, NSError *error) {
		XCTAssertTrue(authenticated, @"Should have authenticated succesfully with a valid account.");
		dispatch_semaphore_signal(semaphore);
	}];
	
	if (dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
}

- (void)testAuthenticationWithInvalidAccount
{
	dispatch_group_t semaphores = dispatch_group_create();
	BopplServer *testServer = [BopplFakeServer new];
	
	dispatch_group_enter(semaphores);
	[testServer authenticateAccountWithCompletion:^(BOOL authenticated, NSHTTPURLResponse *response, NSError *error) {
		XCTAssertFalse(authenticated, @"Should not have authenticated succesfully without an account.");
		dispatch_group_leave(semaphores);
	}];
	
	dispatch_group_enter(semaphores);
	testServer.account = self.exampleInvalidAccount;
	[testServer authenticateAccountWithCompletion:^(BOOL authenticated, NSHTTPURLResponse *response, NSError *error) {
		XCTAssertFalse(authenticated, @"Should not have authenticated succesfully with an invalid account.");
		dispatch_group_leave(semaphores);
	}];
	
	if (dispatch_group_wait(semaphores, dispatch_time(DISPATCH_TIME_NOW, TEST_TIMEOUT_TIME_NS))) {
		XCTFail(@"Asynchronous test %s did not finish within the timeout of %f seconds.", __PRETTY_FUNCTION__, TEST_TIMEOUT_TIME_S);
	}
}

@end
