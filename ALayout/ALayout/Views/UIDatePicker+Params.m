//
//  UIDatePicker+Params.m
//  ALayout
//
//  Created by splendourbell on 2018/11/2.
//  Copyright © 2018年 com.aiospace.zone. All rights reserved.
//

#import "UIDatePicker+Params.h"
#import "AViewCreator.h"
#import "UIView+Params.h"

@implementation UIDatePicker(ViewParams)

RegisterView(UIDatePicker);

- (void)parseAttr:(AttributeReader *)attrReader useDefault:(BOOL)useDefault
{
    [super parseAttr:attrReader useDefault:useDefault];

    NSDate *minimumDate = nil;
    NSDate *maximumDate = nil;
    NSDate *date = nil;
    NSString *datePickerMode = nil;
    
    ATTR_ReadAttrEq(minimumDate,    A_minimumDate,      NSDate,     nil);
    ATTR_ReadAttrEq(maximumDate,    A_maximumDate,      NSDate,     nil);
    ATTR_ReadAttrEq(date,           A_date,             NSDate,     NSDate.date);
    ATTR_ReadAttrEq(datePickerMode, A_datePickerMode,   NSString,   @"Date");
    
    UIDatePickerMode pickerMode = UIDatePickerModeDate;
    if([datePickerMode isEqualToString:@"Time"])
    {
        pickerMode = UIDatePickerModeTime;
    }
    else if([datePickerMode isEqualToString:@"Date"])
    {
        pickerMode = UIDatePickerModeDate;
    }
    else if([datePickerMode isEqualToString:@"DateAndTime"])
    {
        pickerMode = UIDatePickerModeDateAndTime;
    }
    else if([datePickerMode isEqualToString:@"DownTimer"])
    {
        pickerMode = UIDatePickerModeCountDownTimer;
    }
    self.datePickerMode = pickerMode;
    self.minimumDate = minimumDate;
    self.maximumDate = maximumDate;
    self.date = date;
}

@end
