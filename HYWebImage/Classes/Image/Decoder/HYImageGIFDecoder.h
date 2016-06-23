//
//  HYImageGIFDecoder.h
//  Pods
//
//  Created by fangyuxi on 16/6/22.
//
//

#import "HYImageDecoder.h"

// no thread-safe
@interface HYImageGIFFrame : HYImageFrame
{
    
}

@property (nonatomic, assign) CGFloat unclampedDelayTime;
@property (nonatomic, assign) NSUInteger loopCount;

@end

// no thread-safe
@interface HYImageGIFDecoder : HYImageDecoder

@end
