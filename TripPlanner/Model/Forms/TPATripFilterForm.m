//
//  TPATripFilterForm.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPATripFilterForm.h"

@implementation TPATripFilterForm

- (NSArray *)fields
{
    return @[
             @{FXFormFieldKey : @"startDate",
               FXFormFieldType : FXFormFieldTypeDate},
             
             @{FXFormFieldKey : @"endDate",
               FXFormFieldType : FXFormFieldTypeDate},
             ];
}

@end
