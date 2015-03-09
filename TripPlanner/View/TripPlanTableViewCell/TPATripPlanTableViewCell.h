//
//  TPATripPlanTableViewCell.h
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TPATripPlanTableViewCell : UITableViewCell

@property (nonatomic, strong) PFObject *planInfo;

+ (NSString *)reuseIdentifier;

@end
