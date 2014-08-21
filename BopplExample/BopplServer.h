//
//  BopplServer.h
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BopplAccount.h"

@interface BopplServer : NSObject

@property (strong, nonatomic) BopplAccount *account;

- (void)authenticateAccountWithCompletion:(void (^)(BOOL authenticated, NSHTTPURLResponse *response, NSError *error))completion;
- (void)getModifierCategoriesForVenue:(NSInteger)venueID completion:(void (^)(NSArray *modifierCategories, NSHTTPURLResponse *response, NSError *error))completion;

@end
