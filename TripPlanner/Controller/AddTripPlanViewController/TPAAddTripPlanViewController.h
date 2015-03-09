//
//  TPAAddTripPlanViewController.h
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXForms.h"
#import <Parse/Parse.h>

@interface TPAAddTripPlanViewController : UIViewController <FXFormControllerDelegate>

@property (nonatomic, strong) PFObject *planEntry;

@end
