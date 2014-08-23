//
//  init_macros.h
//  BopplExample
//
//  Created by Davide De Franceschi on 23/08/14.
//  Copyright (c) 2014 Davide De Franceschi. All rights reserved.
//

#ifndef BopplExample_init_macros_h
#define BopplExample_init_macros_h

#define IF_NIL_RETURN_NIL_AND_LOG(value) \
if (value == nil) { \
NSLog(@"A parameter is nil in %s.", __PRETTY_FUNCTION__); \
return nil; \
}

#define IF_EMPTY_STRING_RETURN_NIL_AND_LOG(value) \
if (![value isKindOfClass:[NSString class]]) { \
NSLog(@"A parameter is not an NSString in %s.", __PRETTY_FUNCTION__); \
return nil; \
} else if ([value isEqualToString:@""]) { \
NSLog(@"A parameter is an empty NSString in %s.", __PRETTY_FUNCTION__); \
return nil; \
}

#define SET_STRING_VAR_TREATING_EMPTY_AS_NIL(var, value) \
if ([value isKindOfClass:[NSString class]] && [value length] > 0) { \
var = value; \
} else { \
var = nil; \
}

#define SET_VAR_OF_TYPE_OR_RETURN_NIL_AND_LOG(var, vartype, value) \
if (value == nil) { \
NSLog(@"Trying to set %s in %s but parameter is nil.", #var, __PRETTY_FUNCTION__); \
return nil; \
} else if (![value isKindOfClass:[vartype class]]) { \
NSLog(@"Trying to set %s as a %@ in %s but parameter is a %@.", #var, [vartype class], __PRETTY_FUNCTION__, [value class]); \
return nil; \
} else { \
var = value; \
}

#endif
