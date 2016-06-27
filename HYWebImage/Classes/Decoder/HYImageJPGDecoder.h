//
//  HYImageJPGDecoder.h
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "HYImageDecoder.h"

// no thread-safe
@interface HYImageJPGFrame : HYImageFrame
{
    
}

/**
 *  这个jpg是否支持渐进式显示
 */
@property (nonatomic, assign) BOOL isProgressiveJPG;

@end

@interface HYImageJPGDecoder : HYImageDecoder

@end
