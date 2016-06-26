//
//  HYImageWebPDecoder.h
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "HYImageDecoder.h"


// no thread-safe
@interface HYImageWebPFrame : HYImageFrame
{
    
}

@end

@interface HYImageWebPDecoder : HYImageDecoder

@property (nonatomic, assign) BOOL no_fancy_upsampling;
@property (nonatomic, assign) BOOL bypass_filtering;
@property (nonatomic, assign) BOOL use_threads;

@end
