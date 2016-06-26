//
//  HYImageWebPDecoder.m
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "HYImageWebPDecoder.h"
#import "decode.h"
#import "mux_types.h"
#import "demux.h"
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation HYImageWebPFrame


@end

@implementation HYImageWebPDecoder

static void _freeWebpFrameImageData(void *info, const void *data, size_t size)
{
    free((void*)data);
}

- (HYImage *)decodeImageData:(NSData *)imageData
{
    CFTimeInterval start = CACurrentMediaTime();
    
    WebPData data;
    WebPDataInit(&data);
    
    data.bytes = (const uint8_t *)[imageData bytes];
    data.size = [imageData length];
    
    WebPDemuxer* demux = WebPDemux(&data);
    
    uint32_t width = WebPDemuxGetI(demux, WEBP_FF_CANVAS_WIDTH);
    uint32_t height = WebPDemuxGetI(demux, WEBP_FF_CANVAS_HEIGHT);
    //uint32_t bgColor = WebPDemuxGetI(demux, WEBP_FF_BACKGROUND_COLOR);
    uint32_t frameCount = WebPDemuxGetI(demux, WEBP_FF_FRAME_COUNT);
    uint32_t loopCount =  WebPDemuxGetI(demux, WEBP_FF_LOOP_COUNT);
    uint32_t flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS);
    
    CGFloat duration = 0;
    BOOL hasBlendMode = NO;
    
    NSMutableArray *imageFrames = [[NSMutableArray alloc] init];
    
    WebPIterator iter;
    if (WebPDemuxGetFrame(demux, 1, &iter))
    {
        WebPDecoderConfig config;
        WebPInitDecoderConfig(&config);
        
        config.input.height = height;
        config.input.width = width;
        config.input.has_alpha = iter.has_alpha;
        config.input.has_animation = flags & ANIMATION_FLAG;
        config.options.no_fancy_upsampling = self.no_fancy_upsampling;
        config.options.bypass_filtering = self.bypass_filtering;
        config.options.use_threads = self.use_threads;
        config.output.colorspace = MODE_RGBA;
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        
        do {
            
            WebPData frame = iter.fragment;
            CGFloat frameDuration = iter.duration / 1000.0;
            if (frameDuration < 0.01){
            
                frameDuration = 0.1;
            }
            
            VP8StatusCode status = WebPDecode(frame.bytes,
                                              frame.size,
                                              &config);
            if (status != VP8_STATUS_OK){
            
                continue;
            }
            
            int imageWidth = 0;
            int imageHeight = 0;
            
            uint8_t *data = WebPDecodeRGBA(frame.bytes,
                                           frame.size,
                                           &imageWidth,
                                           &imageHeight);
            if (data == NULL){
            
                continue;
            }
            
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, imageWidth * imageHeight * 4, _freeWebpFrameImageData);
            
            CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
            
            CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
            
            CGImageRef imageRef = CGImageCreate(imageWidth,
                                                imageHeight,
                                                8,
                                                32,
                                                4 * imageWidth,
                                                colorSpaceRef,
                                                bitmapInfo,
                                                provider,
                                                NULL,
                                                YES,
                                                renderingIntent);
            
            HYImageWebPFrame *imageFrame = [[HYImageWebPFrame alloc] init];
            imageFrame.width = imageWidth;
            imageFrame.height = imageHeight;
            imageFrame.frameTime = frameDuration;
            imageFrame.sourceImage = (__bridge id)(imageRef);
            imageFrame.property = nil;
            [imageFrames addObject: imageFrame];
            
            if (iter.blend_method == 0){
            
                hasBlendMode = YES;
            }
            
            CGImageRelease(imageRef);
            CGDataProviderRelease(provider);
            duration += frameDuration;
            
        } while (WebPDemuxNextFrame(&iter));
        
        CGColorSpaceRelease(colorSpaceRef);
        WebPDemuxReleaseIterator(&iter);
        WebPFreeDecBuffer(&config.output);
    }
    
    WebPDemuxDelete(demux);
    if (imageFrames.count == 0){
    
        return NULL;
    }
    
    CFTimeInterval finish = CACurrentMediaTime();
    
    CFTimeInterval f = finish - start;
    printf("Decode webP:   %8.2f\n", f * 1000);
    
    HYImage *image = [[HYImage alloc] initWithFrames:imageFrames];
    image.animationDuration = duration;
    image.loopCount = loopCount;
    image.width = width;
    image.height = height;
    
//    IKWebPAnimatedImage *animatedImage = [[IKWebPAnimatedImage alloc] initWithImageFrames: imageFrames];
//    float (^toColorf)(uint32_t, int) = ^(uint32_t color, int shift){
//        return (color >> shift) / 255.f;
//    };
//#if TARGET_OS_IPHONE
//    animatedImage.backgroundColor = [IKColor colorWithRed: toColorf(bgColor, 0)
//                                                    green: toColorf(bgColor, 8)
//                                                     blue: toColorf(bgColor, 16)
//                                                    alpha: toColorf(bgColor, 24)];
//#elif TARGET_OS_MAC
//    animatedImage.backgroundColor = [IKColor colorWithDeviceRed: toColorf(bgColor, 0)
//                                                          green: toColorf(bgColor, 8)
//                                                           blue: toColorf(bgColor, 16)
//                                                          alpha: toColorf(bgColor, 24)];
//#endif
//    
//    animatedImage.totalTime = totalTime;
//    animatedImage.imageWidth = width;
//    animatedImage.imageHeight = height;
//    animatedImage.hasBlendMode = hasBlendMode;
    return image;
}

@end
