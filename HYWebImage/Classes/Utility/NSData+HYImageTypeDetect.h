//
//  NSData+HYImageTypeDetect.h
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import <Foundation/Foundation.h>

/**
 Image file type.
 */
typedef NS_ENUM(NSUInteger, HYImageType) {
    HYImageTypeUnknown = 0,
    HYImageTypeJPEG,
    HYImageTypeJPEG2000,
    HYImageTypeGIF,
    HYImageTypePNG,
    HYImageTypeWebP,
};

@interface NSData(HYImageTypeDetect)

- (HYImageType)detectType;

@end
