//
//  ViewModel.h
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/13/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNModel.h"

@interface MNViewModel : NSObject

@property (nonatomic, strong, readonly) MNModel *model;
@property (nonatomic, strong, readonly) RACCommand *generateCommand;

@property (nonatomic, assign) NSInteger amountOfNames;
@property (nonatomic, assign) ModelGender gender;
@property (nonatomic, assign) NSInteger minNameLength;
@property (nonatomic, assign) NSInteger maxNameLength;
@property (nonatomic, assign) NSInteger order;

@property (nonatomic, strong) NSArray *lastGeneratedNames;

- (instancetype)initWithMaleNames:(NSArray *)maleNames femaleNames:(NSArray *)femaleNames;

@end
