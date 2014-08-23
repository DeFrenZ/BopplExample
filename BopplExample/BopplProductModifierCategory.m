//
//  BopplProductModifierCategory.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductModifierCategory.h"
#import "init_macros.h"

@implementation BopplProductModifierCategory

#pragma mark Initialization

- (instancetype)initWithJSONData:(NSData *)data
{
	IF_NIL_RETURN_NIL_AND_LOG(data)
	NSError *JSONError;
	NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];
	if (dataDictionary == nil) {
		NSLog(@"Error in JSON parsing while initializing a %@ object (%@). Data was %d bytes.", [self class], [JSONError localizedDescription], [data length]);
		return nil;
	}
	
	return [self initWithDictionary:dataDictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		IF_NIL_RETURN_NIL_AND_LOG(dictionary)
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"id"]) _identifier = [dictionary[@"id"] unsignedIntegerValue];
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_categoryDescription, NSString, dictionary[@"category_desc"])
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"override_price"]) _isOverridingPrice = [dictionary[@"override_price"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"mandatory_select"]) _isMandatorySelection = [dictionary[@"mandatory_select"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"multi_select"]) _isMultiSelectable = [dictionary[@"multi_select"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"sort_order"]) _sortOrder = [dictionary[@"sort_order"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"active"]) _isActive = [dictionary[@"active"] boolValue];
		if (dictionary[@"product_modifiers"] != nil) {
			NSMutableArray *tempArray = [@[] mutableCopy];
			BopplProductModifier *tempCategory;
			for (NSDictionary *tempDictionary in dictionary[@"product_modifiers"]) {
				tempCategory = [BopplProductModifier productModifierWithDictionary:tempDictionary];
				[tempArray addObject:tempCategory];
			}
			_productModifiers = [NSArray arrayWithArray:tempArray];
		}
	}
	return self;
}

+ (instancetype)productModifierCategoryWithJSONData:(NSData *)data
{
	return [[self alloc] initWithJSONData:data];
}

+ (instancetype)productModifierCategoryWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

@end
