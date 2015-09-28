//
//  NSObject+JSONSerialization.m
//  PalmDoctorPT
//
//  Created by caiming on 15/7/7.
//  Copyright (c) 2015年 Andrew Shen. All rights reserved.
//

#import "NSObject+JSONSerialization.h"

@implementation NSObject (JSONSerialization)

+(NSString *)jsonStringFromData:(id)data
{
    if (!data) {
        
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(id)dataFormJsonString:(NSString *)jsonString
{
    if (!jsonString) {
        return nil;
    }
    id jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    return jsonObject;
}


@end
