//
//  HYImageGIFDecoder.m
//  Pods
//
//  Created by fangyuxi on 16/6/22.
//
//

#import "HYImageGIFDecoder.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

@implementation HYImageGIFFrame


@end

@implementation HYImageGIFDecoder

- (HYImage *)decodeImageData:(NSData *)data
{
    CFTimeInterval start = CACurrentMediaTime();
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!imageSourceRef)
    {
        return nil;
    }
    size_t frameCount = CGImageSourceGetCount(imageSourceRef);
    if (frameCount == 0)
    {
        CFRelease(imageSourceRef);
        return nil;
    }
    NSMutableArray *imageFrames = [[NSMutableArray alloc] initWithCapacity: frameCount];
    CGFloat gifWidth = 0;
    CGFloat gifHeight = 0;
    CGFloat totalTime = 0;
    
    for (size_t index = 0; index < frameCount; ++index)
    {
        CGImageRef frameImage = CGImageSourceCreateImageAtIndex(imageSourceRef, index, NULL);
        if (!frameImage)
        {
            continue;
        }
        CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, index, NULL);
        
        if (gifWidth == 0 && gifHeight == 0)
        {
            gifWidth =  [(NSNumber*)CFDictionaryGetValue(imageInfo, kCGImagePropertyPixelWidth) floatValue];
            gifHeight = [(NSNumber*)CFDictionaryGetValue(imageInfo, kCGImagePropertyPixelHeight) floatValue];
        }
        
        CFDictionaryRef gifInfo = CFDictionaryGetValue(imageInfo, kCGImagePropertyJFIFDictionary);
        if (!gifInfo)
        {
            CFRelease(frameImage);
            CFRelease(imageInfo);
            continue;
        }
        
        CGFloat unclampedDelayTime = [(NSNumber*)CFDictionaryGetValue(gifInfo, kCGImagePropertyGIFUnclampedDelayTime) floatValue];
        if (unclampedDelayTime < 0.01)
        {
            unclampedDelayTime = 0.1;
        }
        
        totalTime += unclampedDelayTime;
        
        HYImageGIFFrame *frame = [[HYImageGIFFrame alloc] init];
        frame.sourceImage = (__bridge id)frameImage;
        frame.unclampedDelayTime = 0;
        [imageFrames addObject:frame];
        
        CFRelease(imageInfo);
        CGImageRelease(frameImage);
    }
    
    CFRelease(imageSourceRef);
    if (imageFrames.count == 0)
    {
        return nil;
    }
    
    CFTimeInterval finish = CACurrentMediaTime();
    
    CFTimeInterval f = finish - start;
    printf("Decode Gif:   %8.2f\n", f * 1000);
    
    HYImage *image = [[HYImage alloc] initWithFrames:imageFrames];
    image.totalTime = totalTime;
    image.width = gifWidth;
    image.height = gifHeight;
    
    return image;
}

@end
