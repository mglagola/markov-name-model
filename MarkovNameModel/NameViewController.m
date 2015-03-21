//
//  ViewController.m
//  MarkovNameModel
//
//  Created by Mark Glagola on 3/13/15.
//  Copyright (c) 2015 Mark Glagola. All rights reserved.
//

#import "NameViewController.h"
#import "MNViewModel.h"
#import "EditViewController.h"

@implementation NSBundle (Array)

- (NSArray *)buildArrayForResource:(NSString *)resource ofType:(NSString *)type separator:(NSString *)separator {
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:nil];
    contents = [[contents stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *array = [[contents componentsSeparatedByString:separator] mutableCopy];
    [array removeLastObject];
    return [array copy];
}

@end

@interface NameViewController ()

@property (nonatomic, strong) MNViewModel *viewModel;

@end

@implementation NameViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        NSArray *males = [[NSBundle mainBundle] buildArrayForResource:@"namesBoys" ofType:@"txt" separator:@"\n"];
        NSArray *females = [[NSBundle mainBundle] buildArrayForResource:@"namesGirls" ofType:@"txt" separator:@"\n"];
        
        self.viewModel = [[MNViewModel alloc] initWithMaleNames:males femaleNames:females];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.title = @"Generated Names";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];

    @weakify(self);
    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [self.viewModel.generateCommand execute:nil];
    }];
    self.refreshControl = refresh;

    [[[RACObserve(self.viewModel, lastGeneratedNames)
        distinctUntilChanged]
        deliverOnMainThread]
        subscribeNext:^(NSArray *names) {
            @strongify(self);
            [self.tableView reloadData];
        }];
    
    [[[[self.viewModel.generateCommand execute:nil]
        initially:^{
            @strongify(self);
            [self.refreshControl beginRefreshing];
        }] finally:^{
            @strongify(self);
            [self.refreshControl endRefreshing];
        }] subscribeError:^(NSError *error) {
            NSLog(@"Error - %@", error);
        }];
}

#pragma mark - Actions
- (void)editButtonPressed {
    EditViewController *vc = [[EditViewController alloc] initWithViewModel:self.viewModel];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.viewModel.lastGeneratedNames objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.lastGeneratedNames.count;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
