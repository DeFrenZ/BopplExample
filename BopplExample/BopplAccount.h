//
//  BopplAccount.h
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BopplAccount : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

+ (instancetype)accountWithUsername:(NSString *)username andPassword:(NSString *)password;
+ (instancetype)accountWithEncodedAuthorizationString:(NSString *)encodedAuthorizationString;
- (instancetype)initWithUsername:(NSString *)username andPassword:(NSString *)password;
- (instancetype)initWithEncodedAuthorizationString:(NSString *)encodedAuthorizationString;

- (NSString *)encodedAuthorizationString;

- (BOOL)isEqualToAccount:(BopplAccount *)account;

#warning add KeyChain support

@end
