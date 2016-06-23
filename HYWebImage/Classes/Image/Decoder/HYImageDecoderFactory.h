//
//  HYImageDecoderFactory.h
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "HYImageDecoder.h"
#import "HYImageJPGDecoder.h"
#import "HYImageGIFDecoder.h"
#import "HYImageWebPDecoder.h"

// 所有的解码器都不是线程安全的，在多线程环境中，请在外部使用锁

@interface HYImageDecoderFactory : HYImageDecoder

+ (HYImageDecoder *)decoder:(HYImageType)type;

@end
