//
//  EditViewController.m
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/13/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import "EditViewController.h"

@interface EditForm : NSObject <FXForm>

@property (nonatomic, assign) NSInteger amountOfNames;
@property (nonatomic, assign) BOOL male;
@property (nonatomic, assign) NSInteger minNameLength;
@property (nonatomic, assign) NSInteger maxNameLength;
@property (nonatomic, assign) NSInteger order;

@end

@implementation EditForm

- (NSDictionary *)amountOfNamesField {
    return @{FXFormFieldType: FXFormFieldTypeUnsigned};
}

- (NSDictionary *)minNameLengthField {
    return @{FXFormFieldType: FXFormFieldTypeUnsigned};
}

- (NSDictionary *)maxNameLengthField {
    return @{FXFormFieldType: FXFormFieldTypeUnsigned};
}

- (NSDictionary *)orderField {
    return @{FXFormFieldType: FXFormFieldTypeUnsigned};
}

@end

@interface EditViewController ()

@property (nonatomic, weak) EditForm *editForm;

@end

@implementation EditViewController

- (instancetype)initWithViewModel:(MNViewModel *)viewModel {
    if (self = [super init]) {
        self.viewModel = viewModel;
        
        self.formController.form = [EditForm new];
        self.editForm = self.formController.form;
        
        self.editForm.amountOfNames = self.viewModel.amountOfNames;
        self.editForm.male = self.viewModel.gender == ModelGenderMale;
        self.editForm.minNameLength = self.viewModel.minNameLength;
        self.editForm.maxNameLength = self.viewModel.maxNameLength;
        self.editForm.order = self.viewModel.order;
        
        RAC(self.viewModel, amountOfNames) = [RACObserve(self.editForm, amountOfNames).distinctUntilChanged takeUntil:self.rac_willDeallocSignal];
        RAC(self.viewModel, minNameLength) = [RACObserve(self.editForm, minNameLength).distinctUntilChanged takeUntil:self.rac_willDeallocSignal];
        RAC(self.viewModel, maxNameLength) = [RACObserve(self.editForm, maxNameLength).distinctUntilChanged takeUntil:self.rac_willDeallocSignal];
        RAC(self.viewModel, order) = [RACObserve(self.editForm, order).distinctUntilChanged takeUntil:self.rac_willDeallocSignal];
        RAC(self.viewModel, gender) = [RACObserve(self.editForm, male).distinctUntilChanged takeUntil:self.rac_willDeallocSignal];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
}

@end
