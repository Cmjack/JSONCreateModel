//
//  NSObject+JSONSerialization.h
//  PalmDoctorPT
//
//  Created by caiming on 15/7/7.
//  Copyright (c) 2015年 Andrew Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONSerialization)

+(NSString *)jsonStringFromData:(id)data;
+(id)dataFormJsonString:(NSString *)jsonString;

@end
