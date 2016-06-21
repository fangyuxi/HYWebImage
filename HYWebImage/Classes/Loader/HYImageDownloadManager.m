//
//  HYImageDownloadManager.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImageDownloadManager.h"
#import "HYImageDownloadOperation.h"
#import "HYImageCache.h"

@interface HYImageDownloadManager ()<NSURLSessionDelegate,
                            NSURLSessionDataDelegate,
                            NSURLSessionDelegate>

@end

@implementation HYImageDownloadManager

+ (instancetype)sharedManager
{
    static HYImageDownloadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperationQueue *queue = [NSOperationQueue new];
        if ([queue respondsToSelector:@selector(setQualityOfService:)])
        {
            queue.qualityOfService = NSQualityOfServiceBackground;
        }
        manager = [[self alloc] initWithCache:nil operationQueue:nil];
    });
    return manager;
}

- (instancetype)initWithCache:(HYImageCache *)cache
               operationQueue:(nullable NSOperationQueue *)queue
{
    self = [super init];
    if (self)
    {
        _imageCache = cache;
        if (queue)
        {
            _queue = queue;
        }
        else
        {
            _queue = [[NSOperationQueue alloc] init];
            _queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
            
            if ([_queue respondsToSelector:@selector(qualityOfService)]) {
                _queue.qualityOfService = NSQualityOfServiceDefault;
            }
        }
        
        _timeoutInterval = 120.0f;
        _headers = @{ @"Accept" : @"image/webp,image/*;q=0.9" };
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        
        return self;
    }
    return nil;
}

- (nullable HYImageDownloadOperation *)downloadImageWithURL:(NSString *)url
                                                     options:(HYWebImageOptions)options
                                               progressBlock:(HYWebImageDownloadProgressBlock)progressBlock
                                               completeBlock:(HYWebImageDownloadComplete)completeBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = _timeoutInterval;
    request.HTTPShouldHandleCookies = NO;
    request.allHTTPHeaderFields = _headers;
    request.HTTPShouldUsePipelining = YES;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
    HYImageDownloadOperation *operation = [[HYImageDownloadOperation alloc] initOperationWithRequest:task
                                                                                              option:options cacheKey:nil
                                                                                               cache:self.imageCache progressBlock:progressBlock completeBlock:completeBlock];
    [_queue addOperation:operation];
    return operation;
}

#pragma mark NSURLSessionDelegate NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    HYImageDownloadOperation *operation = [self _operationForDataTask:task];
    [operation URLSession:session
                     task:task
      didReceiveChallenge:challenge
        completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    HYImageDownloadOperation *operation = [self _operationForDataTask:dataTask];
    [operation URLSession:session
                 dataTask:dataTask
           didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    HYImageDownloadOperation *operation = [self _operationForDataTask:task];
    [operation URLSession:session
                     task:task
     didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    HYImageDownloadOperation *operation = [self _operationForDataTask:dataTask];
    [operation URLSession:session
                 dataTask:dataTask
       didReceiveResponse:response
        completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler
{
    HYImageDownloadOperation *operation = [self _operationForDataTask:dataTask];
    [operation URLSession:session
                 dataTask:dataTask
        willCacheResponse:proposedResponse
        completionHandler:completionHandler];
}

- (HYImageDownloadOperation *)_operationForDataTask:(NSURLSessionTask *)task
{
    for (HYImageDownloadOperation *operation in self.queue.operations)
    {
        if (operation.task.taskIdentifier == task.taskIdentifier) {
            return operation;
        }
    }
    return nil;
}

@end
