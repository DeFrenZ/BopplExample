//
//  BopplProductCategory.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductCategory.h"
#import "BopplProductGroup.h"
#import "init_macros.h"

@implementation BopplProductCategory

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
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"product_group_id"]) _productGroupIdentifier = [dictionary[@"product_group_id"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"sort_order"]) _sortOrder = [dictionary[@"sort_order"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"active"]) _isActive = [dictionary[@"active"] boolValue];
		if (dictionary[@"sub_categories"] != nil) {
			NSMutableArray *tempArray = [@[] mutableCopy];
			BopplProductCategory *tempCategory;
			for (NSDictionary *tempDictionary in dictionary[@"sub_categories"]) {
				tempCategory = [BopplProductCategory productCategoryWithDictionary:tempDictionary];
				[tempArray addObject:tempCategory];
			}
			_subCategories = [NSArray arrayWithArray:tempArray];
		}
	}
	return self;
}

+ (instancetype)productCategoryWithJSONData:(NSData *)data
{
	return [[self alloc] initWithJSONData:data];
}

+ (instancetype)productCategoryWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

@end
