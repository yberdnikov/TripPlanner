//
//  TPATripFilterForm.h
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

@interface TPATripFilterForm : NSObject <FXForm>

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end
