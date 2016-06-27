//
//  HYImagePNGDecoder.h
//  Pods
//
//  Created by 58 on 16/6/26.
//
//

#import <HYWebImage/HYWebImage.h>

@interface HYImagePNGFrame : HYImageFrame


/**
 *  是否支持隔行扫描
 */
@property (nonatomic, assign, getter=isInterlaceType) BOOL interlaceType;

@end

//支持PNG和APNG

// iOS在 iOS8以上系统可以使用ImageIO进行解码APNG

@interface HYImagePNGDecoder : HYImageDecoder

@end
