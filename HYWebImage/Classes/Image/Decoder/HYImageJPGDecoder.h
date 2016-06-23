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

@property (nonatomic, assign) BOOL isProgressiveJPG;

@end

@interface HYImageJPGDecoder : HYImageDecoder

@end
