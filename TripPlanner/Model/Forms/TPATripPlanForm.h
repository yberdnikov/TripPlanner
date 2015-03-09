//
//  TPATripPlanForm.h
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"
#import <Parse/Parse.h>

@interface TPATripPlanForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *destination;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, copy) NSString *comment;

- (instancetype)initWithPlanEntry:(PFObject *)planEntry;

@end
