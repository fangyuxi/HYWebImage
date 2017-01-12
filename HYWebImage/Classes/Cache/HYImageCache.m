//
//  HYImageCache.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImageCache.h"

@interface HYImageCache ()

@property (nonatomic, readwrite) HYMemoryCache *memCache;
@property (nonatomic, readwrite) HYDiskCache *diskCache;

@end

@implementation HYImageCache

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name andDirectoryPath:nil];
}

- (instancetype)initWithName:(NSString *)name
            andDirectoryPath:(NSString *)directoryPath
{
    self = [super init];
    if (self)
    {
        _memCache = [[HYMemoryCache alloc] initWithName:name];
        _diskCache = [[HYDiskCache alloc] initWithName:name andDirectoryPath:directoryPath];
        return self;
    }
    return nil;
}

@end
