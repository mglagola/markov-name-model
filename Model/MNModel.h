//
//  Model.h
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/12/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSUInteger, ModelGender) {
    ModelGenderMale = 0,
    ModelGenderFemale,
};

@interface MNModel : NSObject

@property (nonatomic, strong) NSArray *maleNames;
@property (nonatomic, strong) NSArray *femaleNames;

- (RACSignal *)generate:(NSUInteger)amountOfNames
         namesForGender:(ModelGender)gender
          withMinLength:(NSUInteger)min
              maxLength:(NSUInteger)max;

- (RACSignal *)generate:(NSUInteger)amountOfNames
         namesForGender:(ModelGender)gender
          withMinLength:(NSUInteger)min
              maxLength:(NSUInteger)max
                  order:(NSUInteger)order;

@end