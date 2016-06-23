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
        break;
            
        case HYImageTypeJPEG:
        return [HYImageJPGDecoder new];
        break;
            
        case HYImageTypeWebP:
        return [HYImageWebPDecoder new];
        break;
            
        default:
            break;
    }
    return nil;
}

@end
