//
//  UIImageView+BitOSS.h
//  SmartCommunity
//
//  Created by zhenchi_chen on 2018/2/11.
//  Copyright © 2018年 bit.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OssNetWorkModel.h"

@interface UIImageView (BitOSS)


/**
 图片加载

 @param key 图片的key
 */
-(void)bitImgeWithKey:(NSString *)key;


/**
 图片加载,带默认图

 @param key 图片的key
 @param defaultImage 默认图m
 */
-(void)bitImgeWithKey:(NSString *)key placeholderImage:(UIImage *)defaultImage;

/**
 图片加载,带默认图

 @param key 图片的key
 @param quality 图片质量(高中低)
 @param defaultImage 默认图
 */
-(void)bitImgeWithKey:(NSString *)key imageQuality:(OSSImageQuality)quality placeholderImage:(UIImage *)defaultImage;

/**
 图片加载,带默认图

 @param key 图片的key
 @param width 图片宽度
 @param defaultImage 默认图
 */
-(void)bitImgeWithKey:(NSString *)key imageWidth:(NSInteger)width placeholderImage:(UIImage *)defaultImage;

/**
 图片加载,带默认图,回调
 
 @param key 图片的key
 @param defaultImage 默认图
 @param completionBlock 回调（image、imageURL）
 */
-(void)bitImgeWithKey:(NSString *)key placeholderImage:(UIImage *)defaultImage completed:(void(^)(UIImage *image,NSURL *imageURL))completionBlock;

@end
