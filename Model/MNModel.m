//
//  Model.m
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/12/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import "MNModel.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation NSString (Model)

- (NSString *)removeCharsInRange:(NSRange)range {
    if (self.length == 0 || range.location+range.length > self.length) return self;
    
    NSMutableString *string = [self mutableCopy];
    [string deleteCharactersInRange:range];
    return [string copy];
}

- (NSString *)removeLastChar {
    return [self removeCharsInRange:NSMakeRange(self.length-1, 1)];
}

- (NSString *)repeatTimes:(NSInteger)times {
    return [@"" stringByPaddingToLength:times*[self length] withString:self startingAtIndex:0];
}

@end


@implementation MNModel

- (instancetype)init {
    if (self = [super init]) {
        srand48(time(0));
    }
    return self;
}

- (RACSignal *)buildProbabilityMapFromNames:(NSArray *)n order:(NSUInteger)order {
    return
        [[[RACSignal return: n]
        map:^NSDictionary *(NSArray *names) {
            NSMutableDictionary *map = [NSMutableDictionary dictionary];
            [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
                //adds "_" * order to front and end of name
                name = [NSString stringWithFormat:@"%@%@%@", [@"_" repeatTimes:order], name, [@"_" repeatTimes:order]];
                
                NSUInteger length = name.length - order;
                for (NSUInteger i = 0; i < length; i++) {
                    NSMutableString *key = [NSMutableString new];
                    for (NSInteger orderIndex = 0; orderIndex <= order; orderIndex++) {
                        unichar c = [name characterAtIndex:i+orderIndex];
                        [key appendFormat:@"%C", c];
                    }
                    
                    NSInteger curCount = [[map objectForKey:key] integerValue];
                    [map setObject:@(curCount+1) forKey:key];
                }
            }];
            
            return map;
        }]
        map:^NSDictionary *(NSMutableDictionary *map) {
            //calculate probability
            NSArray *keys = [map allKeys];
            while (keys.count > 0) {
                NSString *prefix = [[keys firstObject] removeLastChar];
                
                NSArray *prefixedKeys = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", prefix]];
                NSArray *prefixedValues = [map objectsForKeys:prefixedKeys notFoundMarker:@0];
                
                NSInteger const Sum =
                [[prefixedValues
                  reduce:^NSNumber *(NSNumber *accumulator, NSNumber *object) {
                      return @(accumulator.integerValue + object.integerValue);
                  }]
                 integerValue];
                
                [prefixedKeys each:^(NSString *key) {
                    CGFloat probability = [[map objectForKey:key] floatValue] / Sum;
                    [map setObject:@(probability) forKey:key];
                }];
                
                keys = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", prefixedKeys]];
            }
            return [map copy];
        }];
}

- (RACSignal *)buildNameFromProbabilityMap:(NSDictionary *)map
                        generatedFromNames:(NSArray *)names
                                 minLength:(NSUInteger)minLength
                                 maxLength:(NSUInteger)maxLength
                                     order:(NSUInteger)order {
    NSParameterAssert(map);
    NSParameterAssert(minLength != 0);
    NSParameterAssert(maxLength != 0);
    NSParameterAssert(order != 0);
    NSParameterAssert(minLength < maxLength);
    
    @weakify(self);

    /*
     * - Start with a blank = `_` * `order`
     * - Generate a `random` number 0-1
     * - Use random to find the next letter
     */
    
    NSString *startOfName = [@"_" repeatTimes:order];
    
    return
        [[[RACSignal return:startOfName]
        map:^NSString *(NSString *name) {
            do {
                double const Rand = drand48();
                
                NSString *prefix = [name substringFromIndex:name.length-order];
                NSArray *keys = [[map allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", prefix]];
                NSArray *values = [map objectsForKeys:keys notFoundMarker:@(-1)];
                
                NSUInteger const Count = values.count;
                CGFloat previousProbability = 0;
                for (NSUInteger i = 0; i < Count; i++) {
                    CGFloat curProbability = [[values objectAtIndex:i] floatValue];
                    if (Rand >= previousProbability && Rand <= previousProbability + curProbability) {
                        NSString *foundString = [keys objectAtIndex:i];
                        name = [name stringByAppendingString:[foundString substringFromIndex:foundString.length-1]];
                        break;
                    }
                    previousProbability += curProbability;
                }
            } while ([name characterAtIndex:name.length-1] != '_');
            
            //remove all _ chars
            return [name stringByReplacingOccurrencesOfString:@"_" withString:@""];
        }]
        flattenMap:^RACStream *(NSString *name) {
            @strongify(self);
            
            //generate a new name if name doesn't satisify:
            if (name.length < minLength || name.length > maxLength || [names containsObject:name]) {
                return [self buildNameFromProbabilityMap:map generatedFromNames:names minLength:minLength maxLength:maxLength order:order];
            }
            
            return [RACSignal return:name];
        }];
}

- (RACSignal *)buildNames:(NSUInteger)amountOfNames
       fromProbabilityMap:(NSDictionary *)map
       generatedFromNames:(NSArray *)names
                minLength:(NSUInteger)minLength
                maxLength:(NSUInteger)maxLength
                    order:(NSUInteger)order {
    NSParameterAssert(map);
    NSParameterAssert(amountOfNames != 0);
    NSParameterAssert(minLength != 0);
    NSParameterAssert(maxLength != 0);
    NSParameterAssert(order != 0);
    
    RACSignal *signal = [self buildNameFromProbabilityMap:map generatedFromNames:names minLength:minLength maxLength:maxLength order:order];
    for (NSInteger i = 1; i < amountOfNames; i++) {
        signal = [signal merge:[self buildNameFromProbabilityMap:map generatedFromNames:names minLength:minLength maxLength:maxLength order:order]];
    }
    return signal;
}

#pragma mark - Generating name
- (RACSignal *)generate:(NSUInteger)amountOfNames
         namesForGender:(ModelGender)gender
          withMinLength:(NSUInteger)min
              maxLength:(NSUInteger)max {
    return [self generate:amountOfNames namesForGender:gender withMinLength:min maxLength:max order:2];
}

- (RACSignal *)generate:(NSUInteger)amountOfNames
         namesForGender:(ModelGender)gender
          withMinLength:(NSUInteger)min
              maxLength:(NSUInteger)max
                  order:(NSUInteger)order {

    NSArray *names = nil;
    switch (gender) {
        case ModelGenderMale:
            NSAssert(self.maleNames, @"maleNames not set");
            names = self.maleNames;
            break;
        case ModelGenderFemale:
            NSAssert(self.femaleNames, @"femaleNames not set");
            names = self.femaleNames;
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Gender is invalid"];
            break;
    }
    
    
    return [[self buildProbabilityMapFromNames:names order:order]
                flattenMap:^RACStream *(NSDictionary *map) {
                    return [self buildNames:amountOfNames
                         fromProbabilityMap:map
                         generatedFromNames:names
                                  minLength:min
                                  maxLength:max
                                      order:order];
                }];
}

@end
