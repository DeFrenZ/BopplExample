//
//  BopplProductModifierCategory.h
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BopplProductModifierCategory : NSObject

@property (nonatomic) NSUInteger identifier;
@property (strong, nonatomic) NSString *categoryDescription;
@property (nonatomic) BOOL isOverridingPrice;
@property (nonatomic) BOOL isMandatorySelection;
@property (nonatomic) BOOL isMultiSelectable;
@property (nonatomic) NSUInteger sortOrder;
@property (nonatomic) BOOL isActive;
@property (strong, nonatomic) NSArray *productModifiers;

+ (instancetype)productModifierCategoryWithJSONData:(NSData *)data;
+ (instancetype)productModifierCategoryWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithJSONData:(NSData *)data;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
