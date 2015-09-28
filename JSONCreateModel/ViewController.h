//
//  ViewController.h
//  S
//
//  Created by caiming on 15/8/24.
//  Copyright (c) 2015年 caiming. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
    kString = 0,
    kNumber = 1,
    kArray  = 2,
    kDictionary = 3,
    kBool   = 4,
    kId = 5,
}JsonValueType;

@interface ViewController : NSViewController


@end

