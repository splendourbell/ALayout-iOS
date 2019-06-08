//
//  AttributeReader+UIColor.h
//  ALayout
//
//  Created by splendourbell on 2017/4/24.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "AttributeReader.h"

@interface AttributeReader(UIColor)

- (UIColor*)parse_UIColor:(id)value default:(UIColor*)defValue;

@end
