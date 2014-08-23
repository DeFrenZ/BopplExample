//
//  BopplProductModifier.m
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#import "BopplProductModifier.h"
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
		SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(_modifierDescription, NSString, dictionary[@"modifier_desc"])
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

@end
