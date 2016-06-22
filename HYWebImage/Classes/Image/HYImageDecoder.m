//
//  HYImageDecoder.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImageDecoder.h"

@implementation HYImageDecoder

+ (HYImageDecoder *)decoder
{
    return [[[self class] alloc] init];
}

- (HYImage *)decodeImageData:(NSData *)data
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
