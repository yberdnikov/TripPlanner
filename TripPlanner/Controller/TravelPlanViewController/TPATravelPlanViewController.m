//
//  TPATravelPlanViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPATravelPlanViewController.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>
#import <NSDate+Calendar.h>
#import "NSDate+Utilities.h"

@interface TPATravelPlanViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *reportWebView;
@end

@implementation TPATravelPlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Next Month Plans", nil);

    [self loadNextMonthsPlans];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateTripPlansReport:(NSArray *)plans
{
    NSMutableString *reportHTMLString = [[NSMutableString alloc] init];
    
    NSDate *nextMonthDate = [[NSDate date] dateByAddingMonth:1];
    
    [reportHTMLString appendFormat:@"<center><h3>Trips Plan Report %@ - %@</h3></center>", [[nextMonthDate dateMonthStart] shortDateString],
     [[nextMonthDate dateMonthEnd] shortDateString]];
    
    [reportHTMLString appendString:@"<hr>"];
    
    [plans enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
        [reportHTMLString appendFormat:@"<i>Destination</i>: <strong>%@</strong><br>", obj[@"destination"]];
        [reportHTMLString appendFormat:@"<i>Start Date</i>: <strong>%@</strong><br>", [[NSDate dateWithTimeIntervalSince1970:[obj[@"startDate"] doubleValue]] mediumDateString]];
        [reportHTMLString appendFormat:@"<i>End Date</i>: <strong>%@</strong><br>", [[NSDate dateWithTimeIntervalSince1970:[obj[@"endDate"] doubleValue]] mediumDateString]];
        
        if ([obj[@"comment"] isKindOfClass:[NSString class]] && [obj[@"comment"] length])
            [reportHTMLString appendFormat:@"<i>Comment</i>: <em>%@</em><br>", obj[@"comment"]];
        
        [reportHTMLString appendString:@"<hr>"];
    }];
    
    [self.reportWebView loadHTMLString:reportHTMLString baseURL:nil];
}

#pragma mark - Server API communication

- (void)loadNextMonthsPlans
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    PFQuery *query = [PFQuery queryWithClassName:@"TPATripPlan"];
    [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    NSDate *nextMonthDate = [[NSDate date] dateByAddingMonth:1];
    
    [query whereKey:@"startDate" greaterThanOrEqualTo:@([[nextMonthDate dateMonthStart] timeIntervalSince1970])];
    [query whereKey:@"startDate" lessThanOrEqualTo:@([[nextMonthDate dateMonthEnd] timeIntervalSince1970])];
    
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        __typeof(weakSelf) strongSelf = weakSelf;
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            [UIAlertView showErrorWithMessage:error.localizedDescription handler:nil];
            return;
        }
        
        if (!objects.count)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"No Trip Plans", nil)
                               message:NSLocalizedString(@"You don't have any trip plans for next month", nil) handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                   [strongSelf.navigationController popViewControllerAnimated:YES];
                               }];
            return;
        }
        
        [strongSelf generateTripPlansReport:objects];
    }];
}

@end
