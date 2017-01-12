//
//  HYImageCache.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "HYCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYImageCache : NSObject

/**
 *  内存缓存 可配置
 */
@property (nonatomic, readonly) HYMemoryCache *memCache;
/**
 *  闪存缓存 可配置
 */
@property (nonatomic, readonly) HYDiskCache *diskCache;

/**
 *  Do not use below init methods
 *
 *  @return nil
 */
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 *  初始化方法
 *
 *  @param name 缓存的名字，如果有多个缓存，请区分名字，name会显示在调用栈中
                闪存缓存使用默认地址
 *
 *  @return 缓存对象
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  指定初始化方法
 *
 *  @param name          缓存的名字，如果有多个缓存，请区分名字，name会显示在调用栈中
 *  @param directoryPath 闪存缓存的地址
 *
 *  @return cache
 */
- (instancetype)initWithName:(NSString *)name
            andDirectoryPath:(NSString * _Nullable)directoryPath NS_DESIGNATED_INITIALIZER;



@end

NS_ASSUME_NONNULL_END
