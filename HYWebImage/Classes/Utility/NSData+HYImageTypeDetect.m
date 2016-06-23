//
//  NSData+HYImageTypeDetect.m
//  Pods
//
//  Created by fangyuxi on 16/6/23.
//
//

#import "NSData+HYImageTypeDetect.h"

#define HY_FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))
#define HY_TWO_CC(c1,c2) ((uint16_t)(((c2) << 8) | (c1)))

@implementation NSData(HYImageTypeDetect)

- (HYImageType)detectType
{
    NSUInteger length = self.length;
    if (length < 16) return HYImageTypeUnknown;
    
    const unsigned char *bytes = CFDataGetBytePtr((CFDataRef)self);

    
    uint32_t magic4 = *((uint32_t *)bytes);
    switch (magic4) {
            
        case HY_FOUR_CC('G', 'I', 'F', '8'): { // GIF
            return HYImageTypeGIF;
        } break;
            
        case HY_FOUR_CC(0x89, 'P', 'N', 'G'): {  // PNG
            uint32_t tmp = *((uint32_t *)(bytes + 4));
            if (tmp == HY_FOUR_CC('\r', '\n', 0x1A, '\n')) {
                return HYImageTypePNG;
            }
        } break;
            
        case HY_FOUR_CC('R', 'I', 'F', 'F'): { // WebP
            uint32_t tmp = *((uint32_t *)(bytes + 8));
            if (tmp == HY_FOUR_CC('W', 'E', 'B', 'P')) {
                return HYImageTypeWebP;
            }
        } break;
    }
    
    // JPG             FF D8 FF
    if (memcmp(bytes,"\377\330\377",3) == 0){
    
        return HYImageTypeJPEG;
    }
    
    
    return HYImageTypeUnknown;
}
@end
