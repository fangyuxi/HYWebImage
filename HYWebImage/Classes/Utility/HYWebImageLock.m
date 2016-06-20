//
//  HYWebImageLock.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYWebImageLock.h"
#import <pthread.h>

@implementation HYWebImageLock{

#ifdef LockDebug
    NSLock *_lock;
    NSRecursiveLock *_recursiveLock;
#else
    pthread_mutex_t _mutex;
    
#endif
    
}

- (void)dealloc
{
#ifndef LockDebug
     pthread_mutex_destroy(&_mutex);
#endif
}

- (instancetype)initWithName:(NSString *)name
                    lockType:(HYWebImageLockType)type
{
    self = [super init];
    if (self)
    {
#ifdef LockDebug
        if (type == HYWebImageLockTypeNonRecursive)
        {
            _lock = [[NSLock alloc] init];
        }
        else
        {
            _recursiveLock = [[NSRecursiveLock alloc] init];
        }
        
        if (name.length > 0)
        {
            [_lock setName:name];
            [_recursiveLock setName:name];
        }
#else
        pthread_mutexattr_t attr;
        
        pthread_mutexattr_init(&attr);
        if (type == HYWebImageLockTypeRecursive)
        {
            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
        }
        pthread_mutex_init(&_mutex, &attr);
#endif
        return self;
    }
    return nil;
}

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name lockType:HYWebImageLockTypeNonRecursive];
}

- (void)lock
{
#ifdef LockDebug
    [_lock lock];
    [_recursiveLock lock];
#else
    pthread_mutex_lock(&_mutex);
#endif
}

- (void)unLock
{
#ifdef LockDebug
    [_lock unlock];
    [_recursiveLock unlock];
#else
    pthread_mutex_unlock(&_mutex);
#endif
}

@end




