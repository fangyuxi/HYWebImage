//
//  HYProgressiveImage.m
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import "HYProgressiveImage.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "HYImage.h"
#import "HYImageFrame.h"

@interface HYProgressiveImage ()

@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, assign) int64_t expectedNumberOfBytes;
@property (nonatomic, assign) CGImageSourceRef imageSource;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) HYImage *image;

@end

@implementation HYProgressiveImage

- (instancetype)init
{
     if (self = [super init])
     {
    
        _imageSource = CGImageSourceCreateIncremental(NULL);;
        self.size = CGSizeZero;
     }
    
     return self;
}

- (void)dealloc
{
    if (self.imageSource)
    {
        CFRelease(_imageSource);
    }
}


- (HYImage *)updateImageData:(NSData *)data
               expectedBytes:(int64_t)expectedNumberOfBytes
{
    //[self.lock lock];
    if (self.mutableData == nil)
    {
        NSUInteger bytesToAlloc = 0;
        if (expectedNumberOfBytes > 0)
        {
            bytesToAlloc = (NSUInteger)expectedNumberOfBytes;
        }
        
        self.mutableData = [[NSMutableData alloc] initWithCapacity:bytesToAlloc];
        self.expectedNumberOfBytes = expectedNumberOfBytes;
    }
    
    [self.mutableData appendData:data];
    
//    while ([self hasCompletedFirstScan] == NO && self.scannedByte < self.mutableData.length) {
//#if DEBUG
//        CFTimeInterval start = CACurrentMediaTime();
//#endif
//        NSUInteger startByte = self.scannedByte;
//        if (startByte > 0) {
//            startByte--;
//        }
//        if ([self scanForSOSinData:self.mutableData startByte:startByte scannedByte:&_scannedByte]) {
//            self.sosCount++;
//        }
//#if DEBUG
//        CFTimeInterval total = CACurrentMediaTime() - start;
//        self.scanTime += total;
//#endif
//    }
    
    if (self.imageSource){
        
        CGImageSourceUpdateData(self.imageSource, (CFDataRef)self.mutableData, NO);
    }
    
    CGImageRef frameImage = CGImageSourceCreateImageAtIndex(self.imageSource, 0, NULL);
    HYImageFrame *frame = [[HYImageFrame alloc] init];
    frame.sourceImage = (__bridge id)frameImage;
    
    if (!self.image) {
        
        self.image = [[HYImage alloc] initWithFrames:[NSArray arrayWithObject:frame]];
    }
    else {
    
        [self.image updateFrames:[NSArray arrayWithObject:frame]];
    }
    
    return self.image;
    //[self.lock unlock];
}

@end
