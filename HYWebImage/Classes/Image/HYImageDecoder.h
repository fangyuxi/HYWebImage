//
//  HYImageDecoder.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "HYImage.h"
#import "HYImageFrame.h"

/** 解码器的基类 **/

@interface HYImageDecoder : NSObject

+ (HYImageDecoder *)decoder;

- (HYImage *)decodeImageData:(NSData *)data;

@end
