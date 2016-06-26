//
//  HYImageFrame.h
//  Pods
//
//  Created by fangyuxi on 16/6/22.
//
//

#import <Foundation/Foundation.h>

/** 动画图片中的一帧 **/

@interface HYImageFrame : NSObject

@property (nonatomic, strong) id sourceImage;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) UIImageOrientation orientation;
@property (nonatomic, assign) NSTimeInterval frameTime;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;

@property (nonatomic, strong) NSDictionary *property;


@end
