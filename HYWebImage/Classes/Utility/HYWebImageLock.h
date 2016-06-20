//
//  HYWebImageLock.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>


// debug模式使用NSLock和NSRecursiveLock 方便调试
// Release模式使用pthread_mutex_t 提高效率
#define LockDebug

typedef NS_ENUM(NSUInteger, HYWebImageLockType) {
   
    HYWebImageLockTypeNonRecursive = 0, // Default
    HYWebImageLockTypeRecursive,
};

@interface HYWebImageLock : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(NSString *)name
                    lockType:(HYWebImageLockType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)name;

- (void)lock;
- (void)unLock;

@end
