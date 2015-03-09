//
//  TPATripPlanTableViewCell.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPATripPlanTableViewCell.h"

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
}

@end
