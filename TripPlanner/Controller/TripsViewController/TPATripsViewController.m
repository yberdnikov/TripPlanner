//
//  TPATripsViewController.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPATripsViewController.h"
#import "UIAlertView+Blocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>
#import "TPATripPlanTableViewCell.h"

static const NSInteger kMaxNumberOfRowsPerFetch = 20;

@interface TPATripsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UILabel *noReccordsFoundLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTripPlanBarButton;

@property (nonatomic,strong) NSMutableArray *contentDataSource;

@property (nonatomic, assign) BOOL isNextDataChunkAvailable;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) NSUInteger lastFetchedRow;

@property (nonatomic, strong) NSDate *filterFromDate;
@property (nonatomic, strong) NSDate *filterToDate;

@end

@implementation TPATripsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Trips", nil);
    
    
    [self.contentTableView registerNib:[UINib nibWithNibName:@"TPATripPlanTableViewCell" bundle:nil]
                forCellReuseIdentifier:[TPATripPlanTableViewCell reuseIdentifier]];
    self.contentTableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![PFUser currentUser])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentAuthenticationController];
        });
    }
    else
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [self loadData:0 withLimit:kMaxNumberOfRowsPerFetch];
    }
}

#pragma mark - User authentication

- (void)presentAuthenticationController
{
    UINavigationController *authenticationController = [self.storyboard instantiateViewControllerWithIdentifier:@"authenticationNavigationController"];
    authenticationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:authenticationController animated:NO completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.contentDataSource.count)
        return 44.0f;
    
    return 95.0f;
}

- (CGFloat)heightForTripPlanCellAtIndexPath:(NSIndexPath *)indexPath
{
    static TPATripPlanTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.contentTableView dequeueReusableCellWithIdentifier:[TPATripPlanTableViewCell reuseIdentifier]];
    });
    
    [self configureTripPlanCell:sizingCell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentTableView.bounds), 0.0f);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.contentDataSource.count)
        return 44.0f;

    return [self heightForTripPlanCellAtIndexPath:indexPath];
}

- (void)configureTripPlanCell:(TPATripPlanTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.planInfo = self.contentDataSource[indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //self.filterButton.hidden = (!self.contentDataSource.count && !self.filterToDate && !self.filterFromDate);
    
    if (!self.contentDataSource.count && !self.isLoadingData)
    {
        if (self.filterToDate || self.filterFromDate)
            self.noReccordsFoundLabel.text = NSLocalizedString(@"No trip plans were found", nil);
        else
            self.noReccordsFoundLabel.text = NSLocalizedString(@"Start adding your trip plans data", nil);
        
        self.noReccordsFoundLabel.hidden = NO;
        
        return 0;
    }
    
    self.noReccordsFoundLabel.hidden = YES;
    
    NSInteger rowsCount = self.contentDataSource.count;
    if (self.isNextDataChunkAvailable)
        rowsCount++;
    
    return rowsCount;
}

- (UITableViewCell *)indicatorCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IndicatorCell"];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IndicatorCell"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingIndicator setCenter:CGPointMake(CGRectGetWidth(tableView.frame) / 2,  44.0f / 2)];
    [cell addSubview:loadingIndicator];
    
    [loadingIndicator startAnimating];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger quotesCount = self.contentDataSource.count;
    
    if ((indexPath.row == quotesCount) && self.isNextDataChunkAvailable && !self.isLoadingData)
        [self loadData:self.lastFetchedRow withLimit:kMaxNumberOfRowsPerFetch];
    
    if (indexPath.row == quotesCount && self.isLoadingData)
        return [self indicatorCellForTableView:tableView atIndexPath:indexPath];
    
    TPATripPlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TPATripPlanTableViewCell reuseIdentifier]
                                                                     forIndexPath:indexPath];
    
    [self configureTripPlanCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle)
    {
        case UITableViewCellEditingStyleDelete:
        {
            PFObject *objectToDelete = [self.contentDataSource objectAtIndex:indexPath.row];
            
            [self.contentDataSource removeObjectAtIndex:indexPath.row];
            [self.contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [objectToDelete deleteEventually];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate methods

- (NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Edit", nil);
}

- (void)tableView:(UITableView *)tableView swipeAccessoryButtonPushedForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    JSAAddEntryViewController *addEntryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addEntryViewController"];
//    addEntryViewController.entry = [self.contentDataSource objectAtIndex:indexPath.row];
//    
//    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:addEntryViewController];
//    formSheet.shouldDismissOnBackgroundViewTap = YES;
//    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
//    formSheet.cornerRadius = 8.0;
//    formSheet.presentedFormSheetSize = CGSizeMake(300, 320);
//    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
//    formSheet.shouldCenterVertically = YES;
//    
//    __weak __typeof(MZFormSheetController) *weakFormSheet = formSheet;
//    __weak __typeof(self) weakSelf = self;
//    [addEntryViewController setOnDone:^(PFObject *entry) {
//        [weakFormSheet mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
//        
//        if (!entry)
//            return;
//        
//        [weakSelf.contentDataSource sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
//        [weakSelf.contentTableView reloadData];
//        
//        [weakSelf updateWeekStatisticsLabel];
//    }];
//    
//    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
//        
//    }];
    
    [tableView setEditing:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Server API communication

- (void)loadData:(NSUInteger)startRow withLimit:(NSUInteger)limit
{
    self.isLoadingData = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"TPATripPlan"];
    [query orderBySortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    if (self.filterFromDate)
        [query whereKey:@"date" greaterThanOrEqualTo:@([self.filterFromDate timeIntervalSince1970])];
    
    if (self.filterToDate)
        [query whereKey:@"date" lessThanOrEqualTo:@([self.filterToDate timeIntervalSince1970])];
    
    query.limit = limit;
    query.skip = startRow;
    
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        weakSelf.isLoadingData = NO;
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            weakSelf.isNextDataChunkAvailable = NO;
            
            if (!weakSelf.lastFetchedRow)
            {
                [weakSelf.contentDataSource removeAllObjects];
                [weakSelf.contentTableView reloadData];
                
                [UIAlertView showErrorWithMessage:error.localizedDescription handler:nil];
            }
            
            return;
        }
        
        if (objects.count)
        {
            if (!weakSelf.lastFetchedRow)
            {
                [weakSelf.contentDataSource removeAllObjects];
                [weakSelf.contentTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
            
            [weakSelf.contentDataSource addObjectsFromArray:objects];
            weakSelf.lastFetchedRow += objects.count;
        }
        
        if (objects.count < limit)
            self.isNextDataChunkAvailable = NO;
        else
            self.isNextDataChunkAvailable = YES;
        
        [weakSelf.contentTableView reloadData];
    }];
}

@end
