//
//  HYImageDownloadManager.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>

@class HYImageCache;
@class HYImageDownloadOperation;

NS_ASSUME_NONNULL_BEGIN

/** 加载图片的选项 **/
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

/** complete block 回调的类型 **/
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

/** 图片来源 **/
typedef NS_ENUM(NSUInteger, HYWebImageFrom){
    
    HYWebImageFromNone = 0,
    HYWebImageFromWeb,
    HYWebImageFromCache
};

typedef void(^HYWebImageDownloadProgressBlock)(double progress);

typedef void(^HYWebImageDownloadComplete)(UIImage * __nullable image, HYWebImageCompleteType type, HYWebImageFrom from, NSError * __nullable error);

@interface HYImageDownloadManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nullable, nonatomic, copy) NSDictionary *headers;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nullable, nonatomic, strong) HYImageCache *imageCache;
@property (nonatomic, strong, readonly) NSURLSession *session;

- (instancetype)initWithCache:(nullable HYImageCache *)cache
               operationQueue:(nullable NSOperationQueue *)queue;

- (nullable HYImageDownloadOperation *)downloadImageWithURL:(NSString *)url
                                                     options:(HYWebImageOptions)options
                                               progressBlock:(HYWebImageDownloadProgressBlock)progressBlock
                                               completeBlock:(HYWebImageDownloadComplete)completeBlock;

- (void)cancelAllLoading;

@end

NS_ASSUME_NONNULL_END
