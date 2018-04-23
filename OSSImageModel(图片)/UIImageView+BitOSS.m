//
//  UIImageView+BitOSS.m
//  SmartCommunity
//
//  Created by zhenchi_chen on 2018/2/11.
//  Copyright © 2018年 bit.com. All rights reserved.
//

#import "UIImageView+BitOSS.h"

@implementation UIImageView (BitOSS)

-(void)bitImgeWithKey:(NSString *)key{
    if ([key hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:key]];
        return;
    }
    [OssNetWorkModel imageURLWithKey:key isPublic:NO urlBlock:^(NSString *url) {
        [self sd_setImageWithURL:[NSURL URLWithString:url]];
    }];
}

-(void)bitImgeWithKey:(NSString *)key placeholderImage:(UIImage *)defaultImage{
    if ([key hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:key] placeholderImage:defaultImage];
        return;
    }
    [OssNetWorkModel imageURLWithKey:key isPublic:NO urlBlock:^(NSString *url) {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImage];
    }];
}

-(void)bitImgeWithKey:(NSString *)key imageQuality:(OSSImageQuality)quality placeholderImage:(UIImage *)defaultImage {
    if ([key hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:key] placeholderImage:defaultImage];
        return;
    }
    
    [OssNetWorkModel imageURLWithKey:key isPublic:NO quality:quality urlBlock:^(NSString *url) {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImage];
    }];
}

-(void)bitImgeWithKey:(NSString *)key imageWidth:(NSInteger)width placeholderImage:(UIImage *)defaultImage {
    if ([key hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:key] placeholderImage:defaultImage];
        return;
    }
    
    [OssNetWorkModel imageURLWithKey:key isPublic:NO rewidth:width urlBlock:^(NSString *url) {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImage];
    }];
}

- (void)bitImgeWithKey:(NSString *)key placeholderImage:(UIImage *)defaultImage completed:(void (^)(UIImage *, NSURL *))completionBlock{
    if ([key hasPrefix:@"http"]) {
        [self sd_setImageWithURL:[NSURL URLWithString:key] placeholderImage:defaultImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            completionBlock(image,imageURL);
        }];
        return;
    }
    [OssNetWorkModel imageURLWithKey:key isPublic:NO urlBlock:^(NSString *url) {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            completionBlock(image,imageURL);
        }];
    }];
}

@end
