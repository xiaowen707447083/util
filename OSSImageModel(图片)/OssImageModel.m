//
//  OssImageModel.m
//  SmartCommunity
//
//  Created by zhenchi_chen on 2018/2/11.
//  Copyright © 2018年 bit.com. All rights reserved.
//

#import "OssImageModel.h"

@implementation OssImageModel

-(instancetype)init{
    self = [super init];
    if (self) {//创建的时候,如果发现是第一次,建数据库表
        [self createDataBaseTable]; 
    }
    return self;
}



-(NSDictionary *)getAttribute{
    
    return @{@"key":@"TEXT",
             @"extend1":@"TEXT",
             @"extend2":@"TEXT",
             @"value":@"TEXT"};
    
}

@end
