//
//  HYImageDownloadManager.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, HYWebImageOptions) {
    
    //是否使用磁盘缓存
    HYWebImageOptionIgnoreDiskCache = 1 << 1,
    
    //是否以 Progressive 方式显示图片
    HYWebImageOptionProgressive = 1 << 2,
    
    //允许不受信任的证书
    HYWebImageOptionAllowInvalidSSLCertificates = 1 << 3,
    
    //是否可以在后台下载
    HYWebImageOptionAllowBackgroundTask = 1 << 4,
    
    //是否解码图片
    HYWebImageOptionIgnoreImageDecoding = 1 << 5,
    
    //图片下载完毕之后，对ImageView进行Fade动画
    HYWebImageOptionImageViewFadeAnimation = 1 << 6,
    
    //是否自动将图片设置给ImageView
    HYWebImageOptionAvoidSetImage = 1 << 7,
};

typedef NS_ENUM(NSUInteger, HYWebImageCompleteType){

    //完成图片下载
    HYWebImageCompleteTypeFinish = 1,
    //完成图片一部分下载，以Progressive的方式显示
    HYWebImageCompleteTypeProgress,
    //下载失败
    HYWebImageCompleteTypeError,
    //下载取消
    HYWebImageCompleteTypeCancel
};

typedef void(^HYWebImageDownloadProgressBlock)(double progress);

typedef void(^HYWebImageDownloadComplete)(UIImage * __nullable image, HYWebImageCompleteType type, NSError * __nullable error);

@interface HYImageDownloadManager : NSObject

@end

NS_ASSUME_NONNULL_END
