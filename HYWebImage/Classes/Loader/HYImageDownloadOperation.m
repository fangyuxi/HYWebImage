//
//  HYImageDownloadOperation.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImageDownloadOperation.h"
#import "HYWebImageLock.h"
#import "HYImageGIFDecoder.h"
#import "HYImageJPGDecoder.h"
#import "HYProgressiveImage.h"

static NSThread *NetworkThread = nil;




@interface _HYWebImageBackgourndTask : NSObject

@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;

+ (instancetype)_startBackgroundTask;
- (void)_endTask;

@end


@implementation _HYWebImageBackgourndTask

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.taskId = UIBackgroundTaskInvalid;
        self.taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
            UIBackgroundTaskIdentifier taskId = self.taskId;
            self.taskId = UIBackgroundTaskInvalid;
            
            [[UIApplication sharedApplication] endBackgroundTask:taskId];
        }];
        return self;
    }
    return nil;
}

+ (instancetype)_startBackgroundTask
{
    return [[self alloc] init];
}

- (void)_endTask
{
    UIBackgroundTaskIdentifier taskId = self.taskId;
    self.taskId = UIBackgroundTaskInvalid;
    
    [[UIApplication sharedApplication] endBackgroundTask:taskId];
}

@end

@interface HYImageDownloadOperation ()

@property (nonatomic, strong) HYProgressiveImage *progressiveImageDecoder;

@end


@interface HYImageDownloadOperation ()
{
    HYWebImageLock *_lock;
    NSString *_cacheKey;
    HYImageCache *_cache;
    NSURLSessionDataTask *_task;
    HYWebImageOptions _options;
    
    HYWebImageDownloadProgressBlock _progressBlock;
    HYWebImageDownloadComplete _completeBlock;
    NSMutableData *_data;
}

@property (readwrite, readwrite, getter=isCancelled) BOOL cancelled;
@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;

@property (nonatomic, assign) long long expectedDataSize;

@end

@implementation HYImageDownloadOperation

@synthesize cancelled = _cancelled;
@synthesize executing = _executing;
@synthesize finished  = _finished;


- (void)dealloc
{
    
}

#pragma mark Image Download Thread

- (void) _runDownloadThread
{
    NetworkThread = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(_downloadThreadInterPoint:)
                                              object:nil];
    
    if ([NetworkThread respondsToSelector:@selector(qualityOfService)])
    {
        NetworkThread.qualityOfService = NSQualityOfServiceBackground;
    }
    
    [NetworkThread start];
}

#pragma mark Image Download Thread Inter Point

- (void) _downloadThreadInterPoint:(id)object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"com.fangyuxi.hy.webimage.request"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

#pragma mark HYImageDownloadOperation Init

- (nullable HYImageDownloadOperation *)initOperationWithRequest:(NSURLSessionDataTask *)task
                                                         option:(HYWebImageOptions)options
                                                       cacheKey:(nullable NSString *)key
                                                          cache:(nullable HYImageCache *)cache
                                                  progressBlock:(HYWebImageDownloadProgressBlock)progress
                                                  completeBlock:(HYWebImageDownloadComplete)complete
{
    self = [super init];
    if (self)
    {
        _lock = [[HYWebImageLock alloc] initWithName:[task.originalRequest.URL absoluteString]
                                            lockType:HYWebImageLockTypeRecursive];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [self _runDownloadThread];
        });
        
        self.finished = NO;
        self.executing = NO;
        self.cancelled = NO;
        
        _options = options;
        _task = task;
        _cache = cache;
        _cacheKey = key.length == 0 ? _task.originalRequest.URL.absoluteString : [key copy];
        _progressBlock = [progress copy];
        _completeBlock = [complete copy];
        
        return self;
    }
    return nil;
}

#pragma mark runs on download thread

- (void)_startOperation
{
    if ([self isCancelled])
    {
        return;
    }
    
    //cache
    if (!(_options & HYWebImageOptionIgnoreDiskCache))
    {
        //get image from cache
    }
    
    //else
    self.executing = YES;
    
    [_lock lock];
    [_task resume];
    [_lock unLock];
}

- (void)_cancelOperation
{
    if ([self isFinished])
    {
        return;
    }
    
    [_lock lock];
    [_task cancel];
    [_lock unLock];
}

- (void)_didReceiveImageFromWeb:(HYImage *)image
{
    [_lock lock];
    
    _completeBlock(image, HYWebImageCompleteTypeFinish, HYWebImageFromWeb,nil);
    
    [self _done];
    [_lock unLock];
}

- (void)_didReceiveImageFromCache
{
    [_lock lock];
    
    _completeBlock(nil, HYWebImageCompleteTypeFinish, HYWebImageFromCache,nil);
    
    [self _done];
    [_lock unLock];
}

- (void)_didRecevieError:(NSError *)error
{
    [_lock lock];
    
    _completeBlock(nil, HYWebImageCompleteTypeError, HYWebImageFromNone,error);
    
    [self _done];
    [_lock unLock];
}

- (void)_didRecevieCancelError:(NSError *)error
{
    [_lock lock];
    
    _completeBlock(nil, HYWebImageCompleteTypeCancel, HYWebImageFromNone,error);
    
    [self _done];
    [_lock unLock];
}

#pragma mark NSOperation override method

// out caller
- (void)start
{
    if ([self isCancelled])
    {
        return;
    }
    else if ([self isReady] && ![self isFinished] && ![self isExecuting])
    {
        [_lock lock];
        if (!_task)
        {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorFileDoesNotExist
                                             userInfo:@{NSLocalizedDescriptionKey:@"data task in nil"}];
            _completeBlock(nil, HYWebImageCompleteTypeError, HYWebImageFromNone,error);
            [self _done];
        }
        else
        {
            [self performSelector:@selector(_startOperation)
                         onThread:NetworkThread
                       withObject:nil
                    waitUntilDone:NO
                            modes:@[NSDefaultRunLoopMode]];
        }
        [_lock unLock];
    }
}

// out caller
- (void)cancel
{
    if (!self.isCancelled)
    {
        self.cancelled = YES;
        [self performSelector:@selector(_cancelOperation)
                     onThread:NetworkThread
                   withObject:nil
                waitUntilDone:NO
                        modes:@[NSDefaultRunLoopMode]];
    }
}

- (void)setFinished:(BOOL)finished
{
    [_lock lock];
    
    if (!self.isFinished)
    {
        _finished = finished;
    }
    [_lock unLock];
}

- (BOOL)isFinished
{
    [_lock lock];
    BOOL finish = _finished;
    [_lock unLock];
    
    return finish;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isCancelled
{
    [_lock lock];
    BOOL cancel = _cancelled;
    [_lock unLock];
    
    return cancel;
}

- (void)setCancelled:(BOOL)cancelled
{
    [_lock lock];
    
    if (_cancelled != cancelled)
    {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    
    [_lock unLock];
}

- (void)setExecuting:(BOOL)executing
{
    [_lock lock];
    
    if (_executing != executing)
    {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    
    [_lock unLock];
}

- (BOOL)isExecuting
{
    [_lock lock];
    BOOL executing = _executing;
    [_lock unLock];
    
    return executing;
}

#pragma mark NSURLSessionDelegate NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if ([self isCancelled])
    {
        return;
    }
    
    [_lock lock];
    
    if (data)
    {
        [_data appendData:data];
        
        if (_progressBlock){
            
            _progressBlock([_data length] / (double)self.expectedDataSize);
        }
        
        if (!(_options & HYWebImageOptionProgressive)){
            
            return;
        }
        
        if (data.length <= 16){
        
            return;
        }
        if (_expectedDataSize > 0 && data.length >= _expectedDataSize * 0.99) {
        
            return;
        }
        
        HYImageType type = [_data detectType];
        
        if (type == HYImageTypeUnknown ||
            type == HYImageTypeWebP) {
            
            return;
        }
        
        if (!self.progressiveImageDecoder) {
            
            self.progressiveImageDecoder = [[HYProgressiveImage alloc] init];
        }
        
        HYImage *image = [self.progressiveImageDecoder updateImageData:data expectedBytes:self.expectedDataSize];
        _completeBlock(image, HYWebImageCompleteTypeProgress, HYWebImageFromWeb, nil);
    }
    
    [_lock unLock];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    if (error)
    {
        if (error.code == NSURLErrorCancelled) //cancel
        {
            [self performSelector:@selector(_didRecevieCancelError:)
                         onThread:NetworkThread
                       withObject:error
                    waitUntilDone:NO
                            modes:@[NSDefaultRunLoopMode]];
        }
        else //error
        {
            [self performSelector:@selector(_didRecevieError:)
                         onThread:NetworkThread
                       withObject:error
                    waitUntilDone:NO
                            modes:@[NSDefaultRunLoopMode]];
        }
    }
    else // success
    {
        [_lock lock];
        if (self.progressiveImageDecoder) {
            self.progressiveImageDecoder = nil;
        }
        [_lock unLock];
        
        HYImageDecoder *decoder = [HYImageJPGDecoder decoder];
        
        [_lock lock];
        HYImage *image = [decoder decodeImageData:_data];
        [_lock unLock];
        
        [self performSelector:@selector(_didReceiveImageFromWeb:)
                     onThread:NetworkThread
                   withObject:image
                waitUntilDone:NO
                        modes:@[NSDefaultRunLoopMode]];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    
    if ([self isCancelled])
    {
        return;
    }
    
    NSError *error = nil;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (id) response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode >= 300)
        {
            error = [NSError errorWithDomain:NSURLErrorDomain
                                        code:statusCode
                                    userInfo:nil];
        }
    }
    if (error)
    {
        [self performSelector:@selector(_cancelOperation)
                     onThread:NetworkThread
                   withObject:nil
                waitUntilDone:NO
                        modes:@[NSDefaultRunLoopMode]];
    }
    else
    {
        [_lock lock];
        
        if (response.expectedContentLength)
        {
            self.expectedDataSize = response.expectedContentLength;
        }
        _data = [NSMutableData dataWithCapacity:self.expectedDataSize > 0 ? self.expectedDataSize : 0];
        
        [_lock unLock];
    }
    
    
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler
{
    //不使用NSURLCache
    completionHandler(nil);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if (!(_options & HYWebImageOptionAllowInvalidSSLCertificates))
        {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        else
        {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    }
    else
    {
        if ([challenge previousFailureCount] == 0)
        {
            if (self.credential)
            {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else
            {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
        else
        {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler)
    {
        completionHandler(disposition, credential);
    }
}


#pragma mark clean

- (void) _resetStateMachine
{
    self.finished = YES;
    self.executing = NO;
}

- (void) _done
{
    [self _resetStateMachine];
    _progressBlock = nil;
    _completeBlock = nil;
    _task = nil;
    _data = nil;
}

#pragma mark kvo 

//关闭这三个属性的自动kvo
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"isExecuting"] ||
        [key isEqualToString:@"isFinished"] ||
        [key isEqualToString:@"isCancelled"])
    {
        return NO;
    }
    
    return [super automaticallyNotifiesObserversForKey:key];
}

@end
