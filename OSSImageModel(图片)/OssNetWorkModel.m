//
//  OssNetWorkModel.m
//  SmartCommunity
//
//  Created by zhenchi_chen on 2018/2/11.
//  Copyright © 2018年 bit.com. All rights reserved.
//

#import "OssNetWorkModel.h"
#import "OssImageModel.h"
#import "SDWebImageManager.h"
typedef void(^BlockOSS)(void);


#define oss_bucketName_default               @"bit-test"
#define oss_bucketName_default_product       @"bit-smcm-img"
#define oss_endPoing                         @"oss-cn-beijing.aliyuncs.com"
#define USER_tAccessKey                      @"USER_tAccessKey"
#define USER_tSecretKey                      @"USER_tSecretKey"
#define USER_tToken                          @"USER_tToken"
#define USER_expirationTimeInGMTFormat       @"USER_expirationTimeInGMTFormat"
#define USER_expirationTimeInGMTFormat_local @"USER_expirationTimeInGMTFormat_local"

#define NETWORK_GetOSSToken                   @"v1/oss/sts-token"                                    //获取osstoken

@implementation OssNetWorkModel



#pragma mark - OSS图片相关的内容信息

#pragma mark - 图片上传部分
+(void)uploadImage:(NSData *)imageData BlockOSSUpload:(BlockOSSUpload)BlockOSSUpload{
    return [self uploadImage:imageData BlockOSSUpload:BlockOSSUpload BlockOSSUploadPress:nil];
}

+(void)uploadImage:(NSData *)imageData BlockOSSUpload:(BlockOSSUpload)BlockOSSUpload BlockOSSUploadPress:(BlockOSSUploadPress)BlockOSSUploadPress{
    
    if (!BlockOSSUpload) {//回调名字的不能为空
        return;
    }
    
    //图片命名方式:ap+1+bitUID+_+yyyyMMddHHmmssSSS.jpg
    NSString *oss_bucketName;
    if ([[NetWorkUtil getNetEnvironment] isEqualToString:@"正式"]) {
        oss_bucketName = oss_bucketName_default_product;
    }else{
        oss_bucketName = oss_bucketName_default;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"ap1%@_%@_%@.jpg",[[NSUserDefaults standardUserDefaults] valueForKey:USER_UID],oss_bucketName,[NSString stringWithFormat:@"%@", [CJTool stringFromDate:[NSDate date] withFormatter:@"yyyyMMddHHmmssSSS"]]];
    //如果token已经失效，重新获取token
    NSString *time = [[NSUserDefaults standardUserDefaults] valueForKey:USER_expirationTimeInGMTFormat_local];
    if (!time || [self compareOneDay:[NSDate date] withAnotherDay:time] != -1) {
        NSLog(@"token失效,重新获取");
        [self refreashToken:^{
            NSLog(@"当前上传的链接为:%@",imageName);
            [self realUploadImage:imageData imageName:imageName BlockOSSUpload:BlockOSSUpload BlockOSSUploadPress:BlockOSSUploadPress];
        }];
        return;
    }
    NSLog(@"当前上传的链接为:%@",imageName);
    [self realUploadImage:imageData imageName:imageName BlockOSSUpload:BlockOSSUpload BlockOSSUploadPress:BlockOSSUploadPress];
    
}



+(void)realUploadImage:(NSData *)imageData imageName:(NSString *)imageName BlockOSSUpload:(BlockOSSUpload)BlockOSSUpload BlockOSSUploadPress:(BlockOSSUploadPress)BlockOSSUploadPress{
    
    NSString *oss_bucketName;
    if ([[NetWorkUtil getNetEnvironment] isEqualToString:@"正式"]) {
        oss_bucketName = oss_bucketName_default_product;
    }else{
        oss_bucketName = oss_bucketName_default;
    }
    
    OSSClient *client = [self ossInit];
    OSSPutObjectRequest *put = [OSSPutObjectRequest new];
    put.bucketName = oss_bucketName;
    put.objectKey = imageName;
    put.uploadingData = imageData;
    
    NSLog(@"%@",oss_bucketName);
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"上传进度显示：%lld,%lld,%lld",bytesSent,totalBytesSent,totalBytesExpectedToSend);
        if (BlockOSSUploadPress) {
            BlockOSSUploadPress(bytesSent,totalBytesSent,totalBytesExpectedToSend);
        }
    };
    
    OSSTask *putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"update object success!");
            if (BlockOSSUpload) {
                BlockOSSUpload(imageName);
            }
        }else{
            NSLog(@"upload object failed,error:%ld,%@",task.error.code,task.error);
            if (BlockOSSUpload) {
                BlockOSSUpload(nil);
            }
        }
        return nil;
    }];
}

#pragma mark - 获取图片链接部分

+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic urlBlock:(BlockOSSImageURL)urlBlock{
    return [self imageURLWithKey:key isPublic:isPublic extend1:@"bit1" extend2:@"bit2" urlBlock:urlBlock];
}

+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic quality:(OSSImageQuality)quality urlBlock:(BlockOSSImageURL)urlBlock {
    int q = 1;
    switch (quality) {
        case OSSImageQualityHigh:
            q = (IPHONE_X || IPHONE6PLUS) ? 85 : (IPHONE6 ? 80 : 75);
            break;
        case OSSImageQualityMiddle:
            q = (IPHONE_X || IPHONE6PLUS) ? 55 : (IPHONE6 ? 50 : 45);
            break;
        case OSSImageQualityLow:
            q = (IPHONE_X || IPHONE6PLUS) ? 25 : (IPHONE6 ? 20 : 15);
            break;
    }

    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        //  如果是WiFi,图片质量+10%
        q += 10;
    }
    
    return [self imageURLWithKey:key isPublic:isPublic extend1:[NSString stringWithFormat:@"quality,Q_%d", q] extend2:@"bit2" urlBlock:urlBlock];
}

+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic rewidth:(NSInteger)width urlBlock:(BlockOSSImageURL)urlBlock {
    if (width < 1) {
        width = 1;
    }else if (width > 4096) {
        width = 4096;
    }
    
    
    return [self imageURLWithKey:key isPublic:isPublic extend1:[NSString stringWithFormat:@"resize,w_%ld", width] extend2:@"bit2" urlBlock:urlBlock];
}

+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic extend1:(NSString *)extend1 extend2:(NSString *)extend2 urlBlock:(BlockOSSImageURL)urlBlock{
    
    if (!key) {return;}
    
    //判断数据库是否存在
    OssImageModel *tempModel = [[OssImageModel alloc] init];
    //w100_h100_q90
    NSDictionary *optionDic = @{@"key":key,@"extend1":extend1,@"extend2":extend2};
    NSMutableDictionary *resultDic = [tempModel getSigleResultWithDictionary:optionDic];
    if (resultDic) {
        NSString *value = resultDic[@"value"];
        if (value) {
            NSURL *url = [NSURL URLWithString:value];
            [[SDWebImageManager sharedManager] cachedImageExistsForURL:url completion:^(BOOL isInCache) {
                if (isInCache) {
                    NSLog(@"===>缓存中存在图片");
                    urlBlock(value);
                }else{
                    [[SDWebImageManager sharedManager] diskImageExistsForURL:url completion:^(BOOL isInCache) {
                        if (isInCache) {
                            NSLog(@"===>disk中存在图片");
                            urlBlock(value);
                        }else{
                            [self checkTokenWithKeyReal:key isPublic:isPublic ossImageModel:tempModel dbresultDic:resultDic optionDic:optionDic extend1:extend1 extend2:extend2 urlBlock:urlBlock];
                        }
                    }];
                }
                
            }];
            return;
        }
    }
    
     [self checkTokenWithKeyReal:key isPublic:isPublic ossImageModel:tempModel dbresultDic:resultDic optionDic:optionDic extend1:extend1 extend2:extend2 urlBlock:urlBlock];
    
}

+(void)checkTokenWithKeyReal:(NSString *)key isPublic:(BOOL)isPublic ossImageModel:(OssImageModel *)ossImageModel dbresultDic:(NSMutableDictionary *)dbresultDic optionDic:(NSDictionary *)optionDic extend1:(NSString *)extend1 extend2:(NSString *)extend2 urlBlock:(BlockOSSImageURL)urlBlock{
    
    
    if (isPublic) {
        NSString *result = [self imageURLWithKeyReal:key isPublic:isPublic ossImageModel:ossImageModel dbresultDic:dbresultDic optionDic:optionDic extend1:extend1 extend2:extend2];
        urlBlock(result);
        return;
    }
    
    
    //如果token已经失效，重新获取token
    NSString *time = [[NSUserDefaults standardUserDefaults] valueForKey:USER_expirationTimeInGMTFormat_local];
    __block NSString *resultStr;
    if (!time || [self compareOneDay:[NSDate date] withAnotherDay:time] == 1) {
        NSLog(@"===>调用获取key");
        
        [self refreashToken:^{
            resultStr = [self imageURLWithKeyReal:key isPublic:isPublic ossImageModel:ossImageModel dbresultDic:dbresultDic optionDic:optionDic extend1:extend1 extend2:extend2];
            urlBlock(resultStr);
        }];
        return;
    }
    
    resultStr = [self imageURLWithKeyReal:key isPublic:isPublic ossImageModel:ossImageModel dbresultDic:dbresultDic optionDic:optionDic extend1:extend1 extend2:extend2];
    urlBlock(resultStr);
    
}


+(NSString *)imageURLWithKeyReal:(NSString *)key isPublic:(BOOL)isPublic ossImageModel:(OssImageModel *)ossImageModel dbresultDic:(NSMutableDictionary *)dbresultDic optionDic:(NSDictionary *)optionDic extend1:(NSString *)extend1 extend2:(NSString *)extend2{
    //如果token已经失效，重新获取toke
    NSString *resultStr;
    
    NSString *oss_bucketName;
    NSArray *imageNameArr = [key componentsSeparatedByString:@"_"];
    if (imageNameArr.count > 2) {
        oss_bucketName = imageNameArr[1];//取中间的作为
    }else{
        if ([[NetWorkUtil getNetEnvironment] isEqualToString:@"正式"]) {
            oss_bucketName = oss_bucketName_default_product;
        }else{
            oss_bucketName = oss_bucketName_default;
        }
    }
    
    //key参数在上传文件时候生成的，保存在本地，获取文件时通过key去索引
    if(isPublic){   //公有访问URL
//        resultStr = [NSString stringWithFormat:@"http://%@.%@/%@?x-oss-process=image/resize,w_200/rotate,90",oss_bucketName,oss_endPoing,key];
        
        if (extend1 && ![extend1 isEqualToString:@"bit1"]) {
            resultStr = [NSString stringWithFormat:@"http://%@.%@/%@?x-oss-process=image/%@",oss_bucketName,oss_endPoing,key, extend1];
        }else {
            resultStr = [NSString stringWithFormat:@"http://%@.%@/%@",oss_bucketName,oss_endPoing,key];
        }
    }
    else{      //私有访问URL
        
        NSDate *tempDate = [NSDate date];
        long long int timevalue = (long long int)(tempDate.timeIntervalSince1970 +60);     //设置URL超时时间，当前设置为60秒有效时间
        
        /*
         *加签实际上是一个核对机制。在这里一般将timevalue、bucketname、key、secretKey进行加密并与域名等字段连接，生成URL。然后服务端解析　　　　　 *这些字段进行核对，核对成功则返回正确数据。在生成signature时，以上字段必须添加，还有一些其他属性可以不添加。
         */
        NSString *accessKey = [[NSUserDefaults standardUserDefaults] valueForKey:USER_tAccessKey];
        NSString *secretKey = [[NSUserDefaults standardUserDefaults] valueForKey:USER_tSecretKey];
        NSString *ttoken = [[NSUserDefaults standardUserDefaults] valueForKey:USER_tToken];
        NSString *string;
        if (extend1 && ![extend1 isEqualToString:@"bit1"]) {
            string = [NSString stringWithFormat:@"GET\n\n\n%lld\n/%@/%@?security-token=%@&x-oss-process=image/%@",timevalue,oss_bucketName,key,ttoken,extend1];//不要忘记设定bucketName
        }else {
            string = [NSString stringWithFormat:@"GET\n\n\n%lld\n/%@/%@?security-token=%@",timevalue,oss_bucketName,key,ttoken];//不要忘记设定bucketName
        }
        
//        NSLog(@"******\n%@\n****",string);
        NSString *signature = [OSSUtil calBase64Sha1WithData:string withSecret:secretKey];
        NSString *encodedSignature = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                           (CFStringRef)signature,  NULL,
                                                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                           kCFStringEncodingUTF8));
        
        NSString *ttokenSte = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                    (CFStringRef)ttoken,  NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8));
        //http://{bucket}.endpoint/{objectKey}
        
        if (extend1 && ![extend1 isEqualToString:@"bit1"]) {
            resultStr = [NSString stringWithFormat:@"http://%@.%@/%@?OSSAccessKeyId=%@&Expires=%lld&Signature=%@&security-token=%@&x-oss-process=image/%@",oss_bucketName,oss_endPoing,key,accessKey,timevalue,encodedSignature,ttokenSte,extend1];
        }else {
            resultStr = [NSString stringWithFormat:@"http://%@.%@/%@?OSSAccessKeyId=%@&Expires=%lld&Signature=%@&security-token=%@",oss_bucketName,oss_endPoing,key,accessKey,timevalue,encodedSignature,ttokenSte];//以<>表明的为未传出参数，需要自己修改。
        }

    }
   //        NSLog(@"\n\n%@\n\n\n",urlString);
    if (resultStr) {
        //异步写入数据库
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (dbresultDic) {
                NSLog(@"===>更新表数据");
                [ossImageModel updateDataBase:@{@"value":resultStr} withConditions:optionDic];
            }else{
                NSLog(@"===>加入数据");
                ossImageModel.key = key;
                ossImageModel.value = resultStr;
                ossImageModel.extend1 = extend1;
                ossImageModel.extend2 = extend2;
                [ossImageModel addDataBaseWithObject:ossImageModel];
            }
        });
    }
    
    
    return resultStr;
}

#pragma mark - 客户端初始化部分

OSSClient *client;

+(OSSClient *)ossInit{
    if (!client) {
        id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken *{
            return [self getToken];
        }];
        
        client = [[OSSClient alloc] initWithEndpoint:oss_endPoing credentialProvider:credential];
    }
    return client;
}



+(OSSFederationToken *)getToken{
    
    NSUserDefaults *defaules = [NSUserDefaults standardUserDefaults];
    OSSFederationToken *token = [[OSSFederationToken alloc] init];
    token.tAccessKey = [defaules valueForKey:USER_tAccessKey];
    token.tSecretKey = [defaules valueForKey:USER_tSecretKey];
    token.tToken = [defaules valueForKey:USER_tToken];
    token.expirationTimeInGMTFormat = [defaules valueForKey:USER_expirationTimeInGMTFormat];
    return token;
}


#pragma mark - 网络获取token部分

+(void)refreashToken{
    return [self refreashToken:nil];
}
+(void)refreashToken:(BlockOSS)block{
    
    NSLog(@"触发刷新token");
    
    [self requestMessageWithURL_Get:communityURL path:NETWORK_GetOSSToken parameters:nil withOption:@[NECTWORK_CONFIG_NOALERT] vc:nil WithBlock:^(NSString *resultCode, NSDictionary *post_dic) {
        
        NSString *tokenStr = post_dic[@"data"][@"securityToken"];
        
        NSUserDefaults *defauls = [NSUserDefaults standardUserDefaults];
        [defauls setValue:post_dic[@"data"][@"accessKeyId"] forKey:USER_tAccessKey];
        [defauls setValue:post_dic[@"data"][@"accessKeySecret"] forKey:USER_tSecretKey];
        [defauls setValue:tokenStr forKey:USER_tToken];
        NSString *formatDate = post_dic[@"data"][@"expiration"];
        [defauls setValue:formatDate forKey:USER_expirationTimeInGMTFormat];
        NSDate *locleDate = [self getLocalDateFormateUTCDate:formatDate];
        
        NSString *localDate = [BSXWDateUtil strWithDate:locleDate withForMet:@"dd-MM-yyyy-HHmmss"];
        [defauls setValue:localDate forKey:USER_expirationTimeInGMTFormat_local];
        NSLog(@" ,%@",post_dic);
        if (block) {
            block();
        }
    } errorBlock:^(NSString *resultCode, NSString *reslut_describe) {
        NSLog(@"触发刷新token失败");
        if (block) {
            block();
        }
    }];
    
}

#pragma mark - 工具类方法
//输入的UTC日期格式2013-08-03T04:53:51+0000
+(NSDate *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    return dateFormatted;
}

+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSString *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSDate *dateB = [dateFormatter dateFromString:anotherDay];
    
    NSComparisonResult result = [oneDay compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, dateB);
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
}

@end
