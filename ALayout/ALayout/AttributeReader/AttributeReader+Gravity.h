//
//  AttributeReader+Gravity.h
//  ALayout
//
//  Created by splendourbell on 2017/4/25.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gravity.h"
#import "AttributeReader.h"

@interface AttributeReader(Gravity)

- (GravityMode)read_GravityMode_imp:(NSString*)key default:(GravityMode)defValue;

@end
