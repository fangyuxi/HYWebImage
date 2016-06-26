//
//  HYImageDecoderFactory.m
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "HYImageDecoderFactory.h"

@implementation HYImageDecoderFactory

+ (HYImageDecoder *)decoder:(HYImageType)type
{
    switch (type) {
            
        case HYImageTypeGIF:
        return [HYImageGIFDecoder new];
            
        case HYImageTypeJPEG:
        case HYImageTypeJPEG2000:
        return [HYImageJPGDecoder new];
            
        case HYImageTypeWebP:
        return [HYImageWebPDecoder new];
            
        case HYImageTypePNG:
        return [HYImagePNGDecoder new];
            
        default:
        return nil;
    }
    return nil;
}

@end
