//
//  TPATripPlanTableViewCell.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPATripPlanTableViewCell.h"
#import "NSDate+Utilities.h"

@interface TPATripPlanTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *daysToStartTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysToStartLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation TPATripPlanTableViewCell

+ (NSString *)reuseIdentifier
{
    return @"tripPlanTableViewCell";
}

- (void)awakeFromNib
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MM/dd/yyyy"];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.daysToStartTitleLabel.hidden = YES;
    self.daysToStartLabel.hidden = YES;
}

- (void)setPlanInfo:(PFObject *)planInfo
{
    _planInfo = planInfo;
    if (!_planInfo)
        return;
    
    self.destinationLabel.text = planInfo[@"destination"];
    self.startDateLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[planInfo[@"startDate"] doubleValue]]];
    self.endDateLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[planInfo[@"endDate"] doubleValue]]];
    
    if ([planInfo[@"comment"] isKindOfClass:[NSString class]] && [planInfo[@"comment"] length])
    {
        self.commentLabel.text = planInfo[@"comment"];
        self.commentTitleLabel.text = NSLocalizedString(@"COMMENT", nil);
    }
    else
    {
        self.commentTitleLabel.text = nil;
        self.commentLabel.text = nil;
    }
    
    NSInteger daysToStart = [[[NSDate date] dateAtStartOfDay] daysBeforeDate:[[NSDate dateWithTimeIntervalSince1970:[planInfo[@"startDate"] doubleValue]] dateAtStartOfDay]];
    if (daysToStart > 0)
    {
        self.daysToStartTitleLabel.hidden = NO;
        self.daysToStartLabel.hidden = NO;
        self.daysToStartLabel.text = [NSString stringWithFormat:@"%ld %@", (long)daysToStart, daysToStart > 1 ? NSLocalizedString(@"days", nil) : NSLocalizedString(@"day", nil)];
    }
}

@end
