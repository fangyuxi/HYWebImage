//
//  HYImagePNGDecoder.m
//  Pods
//
//  Created by 58 on 16/6/26.
//
//

#import "HYImagePNGDecoder.h"
#import <ImageIO/ImageIO.h>

@implementation HYImagePNGFrame


@end

@implementation HYImagePNGDecoder

- (HYImage *)decodeImageData:(NSData *)data redraw:(BOOL)reDraw
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
    CGFloat apngWidth = 0;
    CGFloat apngHeight = 0;
    CGFloat totalTime = 0;
    NSUInteger orientationValue = 0;
    NSUInteger loopCount = 0;
    BOOL isInterlaceType = NO;
    
    CGFloat frameDuration = 0;
    
    for (size_t index = 0; index < frameCount; ++index)
    {
        CGImageRef frameImage = CGImageSourceCreateImageAtIndex(imageSourceRef, index, NULL);
        if (!frameImage){
            
            continue;
        }
        CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, index, NULL);
        
        if (index == 0){
            
            apngWidth =  [(NSNumber*)CFDictionaryGetValue(imageInfo, kCGImagePropertyPixelWidth) floatValue];
            apngHeight = [(NSNumber*)CFDictionaryGetValue(imageInfo, kCGImagePropertyPixelHeight) floatValue];
        }
        
        CFDictionaryRef apngInfo = CFDictionaryGetValue(imageInfo, kCGImagePropertyPNGDictionary);
        if (!apngInfo){
            
            CFRelease(frameImage);
            CFRelease(imageInfo);
            continue;
        }
        
        CFTypeRef interlaceType = CFDictionaryGetValue(apngInfo, kCGImagePropertyPNGInterlaceType);
        
        if (interlaceType) {
            
            CFNumberGetValue(interlaceType, kCFNumberNSIntegerType, &isInterlaceType);
        }
        
        CFTypeRef loop = CFDictionaryGetValue(apngInfo, kCGImagePropertyAPNGLoopCount);
        if (loop){
            
            CFNumberGetValue(loop, kCFNumberNSIntegerType, &loopCount);
        }
        
        frameDuration = [(NSNumber*)CFDictionaryGetValue(apngInfo, kCGImagePropertyAPNGUnclampedDelayTime) floatValue];
        if (!frameDuration){
            
            frameDuration = [(NSNumber*)CFDictionaryGetValue(apngInfo, kCGImagePropertyAPNGDelayTime) floatValue];
        }
        
        if (frameDuration < 0.01) {
            
            frameDuration = 0.1;
        }
        
        totalTime += frameDuration;
        
        CFTypeRef value = CFDictionaryGetValue(imageInfo, kCGImagePropertyOrientation);
        if (value){
            
            CFNumberGetValue(value, kCFNumberNSIntegerType, &orientationValue);
        }
        
        if (reDraw) {
            
            frameImage = [self redrawImage:frameImage];
        }
        
        HYImagePNGFrame *frame = [[HYImagePNGFrame alloc] init];
        frame.sourceImage = (__bridge id)frameImage;
        frame.orientation = [self imageOrientationFromEXIFValue:orientationValue];
        frame.index = index;
        frame.width = apngWidth;
        frame.height = apngHeight;
        frame.property = (__bridge NSDictionary *)imageInfo;
        frame.interlaceType = isInterlaceType;
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
    printf("Decode APNG:   %8.2f\n", f * 1000);
    
    HYImage *image = [[HYImage alloc] initWithFrames:imageFrames];
    image.animationDuration = totalTime;
    image.loopCount = loopCount;
    image.width = apngWidth;
    image.height = apngHeight;
    
    return image;

}

@end
