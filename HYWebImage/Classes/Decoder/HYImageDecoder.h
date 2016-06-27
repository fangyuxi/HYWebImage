//
//  HYImageDecoder.h
//  Pods
//
//  Created by fangyuxi on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "HYImage.h"
#import "HYImageFrame.h"

/** 解码器的基类 **/

// no thread-safe
@interface HYImageDecoder : NSObject

/**
 *  创建一个解码器
 *
 *  @return decoder
 */
+ (HYImageDecoder *)decoder;

/**
 *  解码图片
 *
 *  @param data   image data
 *  @param reDraw 是否需要重绘（启用重绘可以提高在显示时候的效率）
 *
 *  @return HYImage
 */
- (HYImage *)decodeImageData:(NSData *)data redraw:(BOOL)reDraw;

/**
 *  将exif中的方向信息转换成 UIImageOrientation
 *
 *  @param value exif orientation
 *
 *  @return UIImageOrientation
 */
- (UIImageOrientation)imageOrientationFromEXIFValue:(NSInteger)value;

/**
 *  重绘，在显示的时候就不需要重新解码图片
 *
 *  @param image CGImage
 *
 *  @return decoded CGImage
 */
- (CGImageRef)redrawImage:(CGImageRef)image;

/**
 *  解码的时候，是否将所有的动画帧都解析到内存中，暂时是都解析到内存中
 */
@property (nonatomic, assign) BOOL preLoadAllAnimationFrame;

@end
