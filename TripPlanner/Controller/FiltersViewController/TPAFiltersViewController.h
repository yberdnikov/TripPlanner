//
//  TPAFiltersViewController.h
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPATripFilterForm.h"

@interface TPAFiltersViewController : UIViewController

@property (nonatomic, strong) TPATripFilterForm *filterFormData;

@property (nonatomic, copy) void (^onDatesSelected)(BOOL cancel);

@end
