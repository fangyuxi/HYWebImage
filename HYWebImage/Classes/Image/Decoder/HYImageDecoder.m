//
//  HYImageDecoder.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImageDecoder.h"
#import <ImageIO/ImageIO.h>

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

- (UIImageOrientation)imageOrientationFromEXIFValue:(NSInteger)value
{
    switch (value)
    {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

@end
