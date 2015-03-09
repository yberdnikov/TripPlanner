//
//  TPATripPlanForm.m
//  TripPlanner
//
//  Created by Yuriy Berdnikov on 3/9/15.
//  Copyright (c) 2015 Yuriy Berdnikov. All rights reserved.
//

#import "TPATripPlanForm.h"

@implementation TPATripPlanForm

- (instancetype)initWithPlanEntry:(PFObject *)planEntry
{
    self = [super init];
    if (self && planEntry)
    {
        _destination = planEntry[@"destination"];
        _startDate = [NSDate dateWithTimeIntervalSince1970:[planEntry[@"startDate"] doubleValue]];
        _endDate = [NSDate dateWithTimeIntervalSince1970:[planEntry[@"endDate"] doubleValue]];
        _comment = planEntry[@"comment"];
    }
    
    return self;
}

- (NSArray *)fields
{
    return @[
             @{FXFormFieldKey : @"destination",
               FXFormFieldTitle : @"",
               FXFormFieldHeader : @"Trip Destination",
               @"textField.autocapitalizationType" : @(UITextAutocapitalizationTypeWords),
               FXFormFieldPlaceholder : @"Destination"},
             
             @{FXFormFieldKey : @"startDate",
               FXFormFieldType : FXFormFieldTypeDate,
               FXFormFieldHeader : @"Trip dates"},
             
             @{FXFormFieldKey : @"endDate",
               FXFormFieldType : FXFormFieldTypeDate},
             
             @{FXFormFieldKey : @"comment",
               FXFormFieldTitle : @"",
               FXFormFieldPlaceholder : @"Comment (optional)",
               FXFormFieldType : FXFormFieldTypeLongText,
               FXFormFieldHeader : @"Trip dates"},
             ];
}

@end
