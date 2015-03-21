//
//  EditViewController.h
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/13/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import "FXForms.h"
#import "MNViewModel.h"

@interface EditViewController : FXFormViewController

@property (nonatomic, strong) MNViewModel *viewModel;

- (instancetype)initWithViewModel:(MNViewModel *)viewModel;

@end
