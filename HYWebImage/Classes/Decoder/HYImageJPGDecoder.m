//
//  HYImageJPGDecoder.m
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "HYImageJPGDecoder.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

@implementation HYImageJPGFrame


@end

@implementation HYImageJPGDecoder

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
    CGFloat width = 0;
    CGFloat height = 0;
    NSInteger orientationValue;
    BOOL isJPGProgressive = NO;
    
    for (size_t index = 0; index < frameCount; ++index)
    {
        CGImageRef frameImage = CGImageSourceCreateImageAtIndex(imageSourceRef, index, NULL);
        if (!frameImage){
            
            continue;
        }
        CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, index, NULL);
        
        if (index == 0)
        {
            width =  [(NSNumber*)CFDictionaryGetValue(imageInfo, kCGImagePropertyPixelWidth) floatValue];
            height = [(NSNumber*)CFDictionaryGetValue(imageInfo, kCGImagePropertyPixelHeight) floatValue];
            
            CFDictionaryRef jpgInfo = CFDictionaryGetValue(imageInfo, kCGImagePropertyTIFFDictionary);
            CFTypeRef value = CFDictionaryGetValue(jpgInfo, kCGImagePropertyJFIFIsProgressive);
            if (value) {
                
                 CFNumberGetValue(value, kCFNumberNSIntegerType, &isJPGProgressive);
            }
        }
        
        CFTypeRef value = CFDictionaryGetValue(imageInfo, kCGImagePropertyOrientation);
        if (value)
        {
            CFNumberGetValue(value, kCFNumberNSIntegerType, &orientationValue);
        }
        
        HYImageJPGFrame *frame = [[HYImageJPGFrame alloc] init];
        frame.index = index;
        frame.sourceImage = (__bridge id)frameImage;
        frame.orientation = [self imageOrientationFromEXIFValue:orientationValue];
        frame.isProgressiveJPG = isJPGProgressive;
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
    printf("Decode JPG:   %8.2f\n", f * 1000);
    
    HYImage *image = [[HYImage alloc] initWithFrames:imageFrames];
    
    return image;
}


@end
