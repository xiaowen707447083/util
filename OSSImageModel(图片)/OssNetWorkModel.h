//
//  OssNetWorkModel.h
//  SmartCommunity
//
//  Created by zhenchi_chen on 2018/2/11.
//  Copyright © 2018年 bit.com. All rights reserved.
//

#import "NetWorkModel.h"
#import <AliyunOSSiOS/OSSService.h>


typedef void(^BlockOSSImageURL)(NSString *url);
typedef void(^BlockOSSUpload)(NSString *imageName);
typedef void(^BlockOSSUploadPress)(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);

/// 图片质量
typedef NS_ENUM(NSUInteger, OSSImageQuality) {
    OSSImageQualityHigh,
    OSSImageQualityMiddle,
    OSSImageQualityLow,
};

@interface OssNetWorkModel : NetWorkModel


/**
 图片上传

 @param imageData 图片的data数据
 @param BlockOSSUpload 结果回调，如果回调的图片名字为空，标识上传失败
 */
+(void)uploadImage:(NSData *)imageData BlockOSSUpload:(BlockOSSUpload)BlockOSSUpload;


/**
 图片上传

 @param imageData 图片的data数据
 @param BlockOSSUpload 结果回调，如果回调的图片名字为空，标识上传失败
 @param BlockOSSUploadPress 图片上传进度结果回调
 */
+(void)uploadImage:(NSData *)imageData BlockOSSUpload:(BlockOSSUpload)BlockOSSUpload BlockOSSUploadPress:(BlockOSSUploadPress)BlockOSSUploadPress;


+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic urlBlock:(BlockOSSImageURL)urlBlock;

/**
 获取图片(绝对质量1%-100%)

 @param key key description
 @param isPublic 是否公共
 @param quality 图片质量(高中低)
 @param urlBlock url
 */
+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic quality:(OSSImageQuality)quality urlBlock:(BlockOSSImageURL)urlBlock;

/**
 获取图片(单边缩略-按宽度)

 @param key key description
 @param isPublic isPublic description
 @param width 宽度(1-4096)
 @param urlBlock url
 */
+(void)imageURLWithKey:(NSString *)key isPublic:(BOOL)isPublic rewidth:(NSInteger)width urlBlock:(BlockOSSImageURL)urlBlock;
@end
