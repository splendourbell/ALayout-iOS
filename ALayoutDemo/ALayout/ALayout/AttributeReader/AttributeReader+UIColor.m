//
//  AttributeReader+UIColor.m
//  ALayout
//
//  Created by splendourbell on 2017/4/24.
//  Copyright © 2017年 Splendour Bell. All rights reserved.
//

#import "AttributeReader+UIColor.h"

@implementation AttributeReader(UIColor)

static int hex_to_int(int hex_char)
{
    if(hex_char >= '0' && hex_char <= '9')
    {
        return hex_char - '0';
    }
    else if((hex_char >= 'a' && hex_char <= 'z')
            || (hex_char >= 'A' && hex_char <= 'Z'))
    {
        hex_char |= 1<<5;// to lower case
        return (hex_char - 'a') + 10;
    }
    return -1;
}

- (UIColor*)parse_UIColor:(id)value default:(UIColor*)defValue
{
    UIColor* retColor = defValue;

    if([value isKindOfClass:NSString.class])
    {
        NSString* colorStr = (NSString*)value;
        NSUInteger length = colorStr.length;
        if(length)
        {
            int a = 0xFF;
            int r = 0x00;
            int g = 0x00;
            int b = 0x00;
            
            if([colorStr characterAtIndex:0] == '#')
            {
                switch(length)
                {
                    case 4://#RGB
                    {
                        unichar hex_r = [colorStr characterAtIndex:1];
                        unichar hex_g = [colorStr characterAtIndex:2];
                        unichar hex_b = [colorStr characterAtIndex:3];
                        r = hex_to_int(hex_r);
                        g = hex_to_int(hex_g);
                        b = hex_to_int(hex_b);
                        
                        if(r >= 0 && g >= 0 && b >= 0)
                        {
                            r |= r << 4;
                            g |= g << 4;
                            b |= b << 4;
                        }
                    }
                        break;
                        
                    case 5://#ARGB
                    {
                        unichar hex_a = [colorStr characterAtIndex:1];
                        unichar hex_r = [colorStr characterAtIndex:2];
                        unichar hex_g = [colorStr characterAtIndex:3];
                        unichar hex_b = [colorStr characterAtIndex:4];
                        a = hex_to_int(hex_a);
                        r = hex_to_int(hex_r);
                        g = hex_to_int(hex_g);
                        b = hex_to_int(hex_b);
                        
                        if(a >= 0 && r >= 0 && g >= 0 && b >= 0)
                        {
                            a |= a << 4;
                            r |= r << 4;
                            g |= g << 4;
                            b |= b << 4;
                        }
                    }
                        break;
                        
                    case 7://#RRGGBB
                    {
                        int rh = hex_to_int([colorStr characterAtIndex:1]);
                        int rl = hex_to_int([colorStr characterAtIndex:2]);
                        int gh = hex_to_int([colorStr characterAtIndex:3]);
                        int gl = hex_to_int([colorStr characterAtIndex:4]);
                        int bh = hex_to_int([colorStr characterAtIndex:5]);
                        int bl = hex_to_int([colorStr characterAtIndex:6]);
                        
                        if(rh >= 0 && rl >= 0 && gh >= 0 && gl >= 0 && bh >= 0 && bl >= 0)
                        {
                            r = (rh << 4) | rl;
                            g = (gh << 4) | gl;
                            b = (bh << 4) | bl;
                        }
                    }
                        break;
                        
                    case 9://#AARRGGBB
                    {
                        int ah = hex_to_int([colorStr characterAtIndex:1]);
                        int al = hex_to_int([colorStr characterAtIndex:2]);
                        int rh = hex_to_int([colorStr characterAtIndex:3]);
                        int rl = hex_to_int([colorStr characterAtIndex:4]);
                        int gh = hex_to_int([colorStr characterAtIndex:5]);
                        int gl = hex_to_int([colorStr characterAtIndex:6]);
                        int bh = hex_to_int([colorStr characterAtIndex:7]);
                        int bl = hex_to_int([colorStr characterAtIndex:8]);
                        
                        if(ah >= 0 && al >= 0 && rh >= 0 && rl >= 0 && gh >= 0 && gl >= 0 && bh >= 0 && bl >= 0)
                        {
                            a = (ah << 4) | al;
                            r = (rh << 4) | rl;
                            g = (gh << 4) | gl;
                            b = (bh << 4) | bl;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                
                retColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
            }
        }
    }
    
    return retColor;
}

@end
