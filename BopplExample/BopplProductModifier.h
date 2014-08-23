//
//  BopplProductModifier.h
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BopplProduct;

@interface BopplProductModifier : NSObject

@property (nonatomic) NSUInteger identifier;
@property (nonatomic) NSUInteger modifierIdentifier;
@property (strong, nonatomic) NSString *modifierDescription;
@property (nonatomic) CGFloat price;
@property (nonatomic) NSUInteger popularity;
@property (nonatomic) BOOL isActive;
@property (nonatomic) NSUInteger productIdentifier;
@property (weak, nonatomic) BopplProduct *product;
// epos_id

+ (instancetype)productModifierWithJSONData:(NSData *)data;
+ (instancetype)productModifierWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
