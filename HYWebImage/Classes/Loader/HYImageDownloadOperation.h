//
//  HYImageDownloadOperation.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "HYImageDownloadManager.h"
#import "HYImageCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYImageDownloadOperation : NSOperation

- (nullable HYImageDownloadOperation *)initOperationWithRequest:(NSURLSessionDataTask *)task
                                                         option:(HYWebImageOptions)options
                                                       cacheKey:(nullable NSString *)key
                                                          cache:(nullable HYImageCache *)cache
                                                  progressBlock:(HYWebImageDownloadProgressBlock)progress
                                                  completeBlock:(HYWebImageDownloadComplete)complete;

@end

NS_ASSUME_NONNULL_END