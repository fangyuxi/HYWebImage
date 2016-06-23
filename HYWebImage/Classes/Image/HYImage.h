//
//  HYImage.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "NSData+HYImageTypeDetect.h"

@class HYImageFrame;

// no thread-safe
@interface HYImage : NSObject
{

}

/**
 *  根据图片帧 创建图片
 *
 *  @param frames 图片帧，数组里面的内容必须是UIImage或者CGImageRef
 *
 *  @return 图片
 */
- (HYImage *)initWithFrames:(NSArray *)frames;

/**
 *  更新图片帧
 *
 *  @param frames 图片帧，数组里面的内容必须是UIImage或者CGImageRef
 */
- (void)updateFrames:(NSArray *)frames;

/**
 *  获取图片某一帧
 *
 *  @param index index
 *
 *  @return 帧
 */
- (HYImageFrame *)frameAtIndex:(NSUInteger)index;

/**
 *  图片帧 如果不是动图 那么数组中只有一帧
 */
@property (nonatomic, readonly, strong) NSArray *frames;

/**
 *  如果是动图，那么返回第一帧，如果不是动图，那么返回原图
 */
@property (nonatomic, readonly, strong) UIImage *singleImage;

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;

/**
 *  动图的时间
 */
@property (nonatomic, assign) NSTimeInterval totalTime;


@end
