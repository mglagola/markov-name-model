//
//  ViewModel.m
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/13/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import "MNViewModel.h"

@implementation MNViewModel

- (instancetype)initWithMaleNames:(NSArray *)maleNames femaleNames:(NSArray *)femaleNames {
    if (self = [super init]) {
        _model = [MNModel new];
        self.model.maleNames = maleNames;
        self.model.femaleNames = femaleNames;
        
        self.amountOfNames = 5;
        self.gender = ModelGenderMale;
        self.minNameLength = 8;
        self.maxNameLength = 15;
        self.order = 2;
        
        @weakify(self);
        _generateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);

            NSMutableArray *array = [NSMutableArray new];
            return
                [[[[[RACSignal return:nil]
                deliverOn:[RACScheduler scheduler]]
                flattenMap:^RACStream *(id value) {
                    return [self.model generate:self.amountOfNames
                                 namesForGender:self.gender
                                  withMinLength:self.minNameLength
                                      maxLength:self.maxNameLength
                                          order:self.order];
                }]
                doNext:^(NSString *name) {
                    [array addObject:name];
                }]
                doCompleted:^{
                    @strongify(self);
                    self.lastGeneratedNames = [array copy];
                }];
        }];
    }
    return self;
}

@end
