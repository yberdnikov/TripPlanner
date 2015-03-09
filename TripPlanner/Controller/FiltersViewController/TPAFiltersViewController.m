//
//  TPAFiltersViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPAFiltersViewController.h"
#import "TPATripFilterForm.h"
#import "UIAlertView+Blocks.h"

@interface TPAFiltersViewController () <FXFormControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (nonatomic, strong) FXFormController *formController;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation TPAFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Filter Plans", nil);
    
    self.contentTableView.tableFooterView = [[UIView alloc] init];

    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.contentTableView;
    self.formController.delegate = self;
    
    self.cancelButton.selected = !!self.filterFormData;
    
    if (!self.filterFormData)
        self.filterFormData = [[TPATripFilterForm alloc] init];
    
    self.formController.form = self.filterFormData;
}

#pragma mark - UIButton selectors

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    if (!sender.selected)
    {
        if (self.onDatesSelected)
            self.onDatesSelected(YES);
        
        return;
    }
    
    sender.selected = NO;
    
    self.filterFormData.startDate = nil;
    self.filterFormData.endDate = nil;
    
    self.formController.form = self.filterFormData;
    [self.contentTableView reloadData];
}

- (IBAction)applyButtonPressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if ([self.filterFormData.startDate timeIntervalSinceDate:self.filterFormData.endDate] > 0)
    {
        [UIAlertView showWarningWithMessage:NSLocalizedString(@"End date can't be earlier than Start date", nil) handler:nil];
        return;
    }
    
    if (self.onDatesSelected)
        self.onDatesSelected(NO);
}

@end
