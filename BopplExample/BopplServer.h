//
//  BopplServer.h
//  BopplExample
//
//  Created by Davide De Franceschi on 20/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BopplAccount.h"

@protocol BopplServerDelegate;

#pragma mark -

@interface BopplServer : NSObject

@property (strong, nonatomic) BopplAccount *account;
@property (weak, nonatomic) id<BopplServerDelegate> delegate;

- (void)authenticateUsername:(NSString *)username withPassword:(NSString *)password;
- (void)getModifierCategoriesForVenue:(NSInteger)venueID;

@end

#pragma mark -

@protocol BopplServerDelegate <NSObject>

@optional
- (void)bopplServer:(BopplServer *)server didAuthenticate:(BOOL)authenticated;
- (void)bopplServer:(BopplServer *)server didReceiveModifierCategories:(NSArray *)modifierCategories forVenueID:(NSInteger)venueID;

@end
