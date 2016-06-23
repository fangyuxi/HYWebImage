//
//  HYImage.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYImage.h"
#import "HYImageFrame.h"

@interface HYImage ()

@property (nonatomic, readwrite, strong) UIImage *singleImage;
@property (nonatomic, readwrite, strong) NSArray *frames;

@end

@implementation HYImage

@synthesize singleImage = _singleImage;

- (HYImage *)initWithFrames:(NSArray *)frames
{
    self = [super init];
    if (self) {

        _frames = frames;
        return self;
    }
    return nil;
}

- (void)updateFrames:(NSArray *)frames
{
    self.singleImage = nil;
    self.frames = frames;
}

- (HYImageFrame *)frameAtIndex:(NSUInteger)index
{
    if (index >= self.frames.count) {
        return nil;
    }

    return [self.frames objectAtIndex:index];
}

- (UIImage *)singleImage
{
    if (_singleImage) {

        return _singleImage;
    }

    if (self.frames.count == 0) {

        return nil;
    }

    HYImageFrame *frame = [self.frames objectAtIndex:0];

    if (frame.sourceImage == NULL) {
        
        return nil;
    }
    
    if ([frame.sourceImage isKindOfClass:[UIImage class]]) {

        _singleImage = frame.sourceImage;
        return _singleImage;
    }

    if (CFGetTypeID((__bridge CFTypeRef)frame.sourceImage) == CGImageGetTypeID()){

        _singleImage = [UIImage imageWithCGImage:(CGImageRef)frame.sourceImage scale:[[UIScreen mainScreen] scale] orientation:frame.orientation];
        return _singleImage;
    }

    return nil;
}

@end
