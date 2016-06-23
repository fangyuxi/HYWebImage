//
//  HYProgressiveImage.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>

@class HYImage;

NS_ASSUME_NONNULL_BEGIN

// no thread-safe
@interface HYProgressiveImage : NSObject

- (HYImage *)updateImageData:(NSData *)data
          expectedBytes:(int64_t)expectedNumberOfBytes;
@end

NS_ASSUME_NONNULL_END