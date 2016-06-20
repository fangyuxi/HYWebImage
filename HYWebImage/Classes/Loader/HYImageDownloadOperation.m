//
//  HYImageDownloadOperation.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImageDownloadOperation.h"
#import "HYWebImageLock.h"

static NSThread *downloadThread = nil;

@interface HYImageDownloadOperation ()
{
    HYWebImageLock *_lock;
}

@property (readwrite, readwrite, getter=isCancelled) BOOL cancelled;
@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) HYWebImageOptions options;

@property (nonatomic, copy) HYWebImageDownloadProgressBlock progress;
@property (nonatomic, copy) HYWebImageDownloadComplete complete;
@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, strong) HYImageCache *cache;

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
    downloadThread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(_downloadThreadInterPoint)
                                                 object:nil];
    
    if ([downloadThread respondsToSelector:@selector(qualityOfService)]) {
        downloadThread.qualityOfService = NSQualityOfServiceBackground;
    }
    else
    {
        downloadThread.threadPriority = 0.2;
    }
    
    [downloadThread start];
}

#pragma mark Image Download Thread Inter Point

- (void) _downloadThreadInterPoint
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
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [self _runDownloadThread];
        });
        
        self.finished = NO;
        self.executing = NO;
        self.cancelled = NO;
        
        self.task = task;
        self.options = options;
        self.cacheKey = key;
        self.progress = progress;
        self.complete = complete;
        
        _lock = [[HYWebImageLock alloc] initWithName:[task.originalRequest.URL absoluteString]
                                            lockType:HYWebImageLockTypeRecursive];
        return self;
    }
    return nil;
}

#pragma mark runs on download thread

- (void)_startOperation
{
    [_lock lock];
    
    if ([self isCancelled]) {
        
    }
    
    [_lock unLock];
}

- (void)_startRequest
{
    
}

- (void)_cancelOperation
{
    
}

#pragma mark NSOperation override method

// out caller
- (void)start
{
    [_lock lock];
    if ([self isCancelled])
    {
        [self performSelector:@selector(_cancelOperation)
                     onThread:downloadThread
                   withObject:nil
                waitUntilDone:NO
                        modes:@[NSDefaultRunLoopMode]];
        return;
    }
    else if ([self isReady] && ![self isFinished] && ![self isExecuting])
    {
        if (!self.task)
        {
            self.finished = YES;
            self.executing = NO;
            
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey:@"data task in nil"}];
            self.complete(nil, HYWebImageCompleteTypeError, error);
        }
        else
        {
            [self performSelector:@selector(_startOperation)
                         onThread:downloadThread
                       withObject:nil
                    waitUntilDone:NO
                            modes:@[NSDefaultRunLoopMode]];
        }
    }
    
    [_lock unLock];
}

// out caller
- (void)cancel
{
    [_lock lock];
    if (!self.isCancelled)
    {
        self.cancelled = YES;
    }
    [_lock unLock];
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


@end
