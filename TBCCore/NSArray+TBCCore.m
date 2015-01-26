//  Copyright (c) 2014 Tabcorp Pty. Ltd. All rights reserved.

#import "NSArray+TBCCore.h"

#import <objc/runtime.h>

@implementation NSArray(TBCCore)

+ (void)load {
    //This swizzling is purely to avoid trampolining through the tbc_map: | tbc_filter: implementations
    {
        IMP imp = class_getMethodImplementation(self, @selector(tbc_arrayByApplyingMap:));
        class_replaceMethod(self, @selector(tbc_map:), imp, "@@:@");
    }
    
    {
        IMP imp = class_getMethodImplementation(self, @selector(tbc_arrayByFilteringWithPredicateBlock:));
        class_replaceMethod(self, @selector(tbc_filter:), imp, "@@:@");
    }
}

- (NSArray *)tbc_map:(TBCCoreMapBlock)block {return [self tbc_arrayByApplyingMap:block];}

#define X(__retType, __initializer) \
    NSParameterAssert(block);\
    __block NSUInteger i = 0;\
    id __strong *objects = (id __strong *)calloc(self.count, sizeof(id));\
    [self enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {\
        id mapped = block(obj);\
        if (mapped) {\
            objects[i++] = mapped;\
        }\
    }];\
    const NSUInteger count = i;\
    __retType *result = __initializer;\
    while ( i > 0 ) {\
        objects[--i] = nil;\
    }\
    free(objects);\
    return result;


- (NSArray *)tbc_arrayByApplyingMap:(TBCCoreMapBlock)block {
    X(NSArray, [NSArray arrayWithObjects:objects count:count]);
}

- (NSMutableArray *)tbc_mutableArrayByApplyingMap:(TBCCoreMapBlock)block {
    X(NSMutableArray, [NSMutableArray arrayWithObjects:objects count:count]);
}

- (NSSet *)tbc_setByApplyingMap:(TBCCoreMapBlock)block {
    X(NSSet, [NSSet setWithObjects:objects count:count]);
}

- (NSMutableSet *)tbc_mutableSetByApplyingMap:(TBCCoreMapBlock)block {
    X(NSMutableSet, [NSMutableSet setWithObjects:objects count:count]);
}

- (NSCountedSet *)tbc_countedSetByApplyingMap:(TBCCoreMapBlock)block {
    X(NSCountedSet, [NSCountedSet setWithObjects:objects count:count]);
}

#undef X

- (NSArray *)tbc_filter:(TBCObjectPredicateBlock)predicateBlock {return [self tbc_arrayByFilteringWithPredicateBlock:predicateBlock];}

#define X(__retType, __initializer)\
    NSParameterAssert(predicateBlock);\
    __block NSUInteger i = 0;\
    id __unsafe_unretained *objects = (id __unsafe_unretained *)calloc(self.count, sizeof(id));\
    [self enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {\
        if( predicateBlock(obj) ) {\
            objects[i++] = obj;\
        }\
    }];\
    const NSUInteger count = i;\
    __retType *result = __initializer;\
    free(objects);\
    return result;\

- (NSArray *)tbc_arrayByFilteringWithPredicateBlock:(TBCObjectPredicateBlock)predicateBlock {
    X(NSArray, [NSArray arrayWithObjects:objects count:count]);
}

- (NSMutableArray *)tbc_mutableArrayByFilteringWithPredicateBlock:(TBCObjectPredicateBlock)predicateBlock {
    X(NSMutableArray, [NSMutableArray arrayWithObjects:objects count:count]);
}

- (NSSet *)tbc_setByFilteringWithPredicateBlock:(TBCObjectPredicateBlock)predicateBlock {
    X(NSSet, [NSSet setWithObjects:objects count:count]);
}

- (NSMutableSet *)tbc_mutableSetByFilteringWithPredicateBlock:(TBCObjectPredicateBlock)predicateBlock {
    X(NSMutableSet, [NSMutableSet setWithObjects:objects count:count]);
}

- (NSCountedSet *)tbc_countedSetByFilteringWithPredicateBlock:(TBCObjectPredicateBlock)predicateBlock {
    X(NSCountedSet, [NSCountedSet setWithObjects:objects count:count]);
}

@end
