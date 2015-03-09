//
//  TPAAddTripPlanViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPAAddTripPlanViewController.h"
#import "TPATripPlanForm.h"
#import "UIAlertView+Blocks.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD.h>

@interface TPAAddTripPlanViewController () <FXFormControllerDelegate>

@property (nonatomic, strong) FXFormController *formController;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation TPAAddTripPlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"New Trip Plan", nil);
    
    self.contentTableView.tableFooterView = [[UIView alloc] init];
    
    self.formController = [[FXFormController alloc] init];
    self.formController.tableView = self.contentTableView;
    self.formController.delegate = self;
    self.formController.form = [[TPATripPlanForm alloc] initWithPlanEntry:self.planEntry];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButton selectors

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender
{
    TPATripPlanForm *tripPlanData = self.formController.form;
    
    if (!tripPlanData.destination.length)
    {
        [UIAlertView showWarningWithMessage:NSLocalizedString(@"Please provide Trip Destination", nil) handler:nil];
        return;
    }
    
    if (!tripPlanData.startDate || !tripPlanData.endDate)
    {
        [UIAlertView showWarningWithMessage:NSLocalizedString(@"Trip Start and End dates should be provided", nil) handler:nil];
        return;
    }
    
    if ([tripPlanData.startDate timeIntervalSinceDate:tripPlanData.endDate] > 0)
    {
        [UIAlertView showWarningWithMessage:NSLocalizedString(@"End date can't be earlier than Start date", nil) handler:nil];
        return;
    }
    
    [self.view endEditing:YES];
    [self saveUserTripData:tripPlanData];
}

#pragma mark - Save data

- (void)saveUserTripData:(TPATripPlanForm *)tripPlanData
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    if (!self.planEntry)
        self.planEntry = [PFObject objectWithClassName:@"TPATripPlan"];

    self.planEntry[@"startDate"] = @([tripPlanData.startDate timeIntervalSince1970]);
    self.planEntry[@"endDate"] = @([tripPlanData.endDate timeIntervalSince1970]);
    self.planEntry[@"destination"] = tripPlanData.destination;
    
    if (tripPlanData.comment.length)
        self.planEntry[@"comment"] = tripPlanData.comment;
    
    self.planEntry[@"user"] = [PFUser currentUser];
    
    __weak __typeof(self) weakSelf = self;
    [self.planEntry saveEventually:^(BOOL succeeded, NSError *error) {
        
        __typeof(weakSelf) strongSelf = weakSelf;
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            [UIAlertView showErrorWithMessage:error.localizedDescription handler:nil];
            return;
        }
        
        [strongSelf.navigationController popViewControllerAnimated:YES];
    }];
}

@end
