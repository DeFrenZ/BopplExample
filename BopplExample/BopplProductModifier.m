//
//  BopplProductModifier.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductModifier.h"
#import "BopplProduct.h"
#import "init_macros.h"

@implementation BopplProductModifier

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
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"modifier_id"]) _modifierIdentifier = [dictionary[@"modifier_id"] unsignedIntegerValue];
		SET_STRING_VAR_TREATING_EMPTY_AS_NIL(_modifierDescription, dictionary[@"modifier_desc"])
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"price"]) _price = [dictionary[@"price"] floatValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"popularity"]) _popularity = [dictionary[@"popularity"] unsignedIntegerValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"active"]) _isActive = [dictionary[@"active"] boolValue];
		IF_NIL_RETURN_NIL_AND_LOG(dictionary[@"product_id"]) _productIdentifier = [dictionary[@"product_id"] unsignedIntegerValue];
		// epos_id
	}
	return self;
}

+ (instancetype)productModifierWithJSONData:(NSData *)data
{
	return [[self alloc] initWithJSONData:data];
}

+ (instancetype)productModifierWithDictionary:(NSDictionary *)dictionary
{
	return [[self alloc] initWithDictionary:dictionary];
}

#pragma mark BopplProductModifiers

+ (NSDictionary *)dictionaryFromProductModifiers:(NSArray *)modifiers
{
	if (modifiers != nil) {
		NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithCapacity:modifiers.count];
		for (BopplProductModifier *currentModifier in modifiers) {
			tempDictionary[@(currentModifier.modifierIdentifier)] = currentModifier;
		}
		return [NSDictionary dictionaryWithDictionary:tempDictionary];
	}
	
	NSLog(@"Trying to index a nil NSArray.");
	return nil;
}

+ (void)linkModifiers:(NSArray *)modifiers toProducts:(NSArray *)products
{
	if (modifiers != nil && products != nil) {
		NSDictionary *indexedProducts = [BopplProduct dictionaryFromProducts:products];
		for (BopplProductModifier *currentModifier in modifiers) {
			currentModifier.product = indexedProducts[@(currentModifier.productIdentifier)];
		}
	}
	
	NSLog(@"Trying to link arrays in %s but at least one is nil.", __PRETTY_FUNCTION__);
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *tempDictionary = [@{} mutableCopy];
	tempDictionary[@"id"] = @(self.identifier);
	tempDictionary[@"modifier_id"] = @(self.modifierIdentifier);
	tempDictionary[@"modifier_desc"] = (self.modifierDescription == nil)? @"" : self.modifierDescription;
	tempDictionary[@"price"] = @(self.price);
	tempDictionary[@"popularity"] = @(self.popularity);
	tempDictionary[@"active"] = @(self.isActive);
	tempDictionary[@"product_id"] = @(self.productIdentifier);
	// epos_id
	
	return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

- (NSData *)JSONData
{
	NSDictionary *tempDictionary = [self dictionaryRepresentation];
	NSError *JSONError;
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:NSJSONWritingPrettyPrinted error:&JSONError];
	if (JSONData == nil) {
		NSLog(@"Error in writing a JSON representation of a %@ object (%@). Dictionary was %@.", [self class], [JSONError localizedDescription], tempDictionary);
		return nil;
	}
	
	return [NSData dataWithData:JSONData];
}

@end
