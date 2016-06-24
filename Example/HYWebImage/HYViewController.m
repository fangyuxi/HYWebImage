//
//  HYViewController.m
//  HYWebImage
//
//  Created by fangyuxi on 06/17/2016.
//  Copyright (c) 2016 fangyuxi. All rights reserved.
//

#import "HYViewController.h"
#import "HYWebImage.h"
#import "HYDispatchQueuePool.h"
#import "HYImageJPGDecoder.h"

@interface HYViewController ()
{
    NSMutableArray *_array;
    UIImageView *imageView;
}

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor whiteColor];
    
    _array = [NSMutableArray array];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    for (NSInteger index = 0; index < 1; ++index) {
    
        dispatch_async([HYDispatchQueuePool queueWithPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT], ^{
            
            [[HYImageDownloadManager sharedManager] downloadImageWithURL:@"http://littlesvr.ca/apng/images/Contact.webp" options:HYWebImageOptionAllowInvalidSSLCertificates | HYWebImageOptionProgressive progressBlock:^(double progress) {
                
                NSLog(@"%f", progress);
                
            } completeBlock:^(HYImage * _Nullable image, HYWebImageCompleteType type, HYWebImageFrom from, NSError * _Nullable error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (type == HYWebImageCompleteTypeFinish || type == HYWebImageCompleteTypeProgress) {
                        
                        imageView.image = image.singleImage;
                        
                        static NSInteger i = 1;
                        
                        NSLog(@"%ld Finish", (long)i);
                        
                        ++i;
                    }
                    
                });
            }];
            
            //[_array addObject:op];
        });
    }
    
//    HYImageJPGDecoder * decoder = [HYImageJPGDecoder new];
//    //NSString *path = [[NSBundle mainBundle] pathForResource:@"mew_progressive" ofType:@"jpg"];
//    UIImage *image = [UIImage imageNamed:@"mew_progressive"];
//    NSData *data = UIImageJPEGRepresentation(image, 1);
//    [decoder decodeImageData:data];
}

//{
//    ColorModel = RGB;
//    DPIHeight = 72;
//    DPIWidth = 72;
//    Depth = 8;
//    Orientation = 1;
//    PixelHeight = 600;
//    PixelWidth = 600;
//    "{Exif}" =     {
//        ColorSpace = 65535;
//        DateTimeDigitized = "2015:08:21 22:01:29";
//        ExifVersion =         (
//                               2,
//                               2,
//                               1
//                               );
//        PixelXDimension = 600;
//        PixelYDimension = 600;
//    };
//    "{JFIF}" =     {
//        IsProgressive = 1;
//    };
//    "{TIFF}" =     {
//        DateTime = "2015:08:24 21:38:22";
//        Orientation = 1;
//        PhotometricInterpretation = 2;
//        ResolutionUnit = 2;
//        Software = "Adobe Photoshop CC 2014 (Macintosh)";
//        XResolution = 72;
//        YResolution = 72;
//    };
//}


- (void)action
{
    int value = arc4random() % 999;
    
    HYImageDownloadOperation *op = [_array objectAtIndex:value];
    
    if (!op.isFinished) {
        
        [op cancel];
        static NSInteger i = 1;
        NSLog(@"%ld cancel", (long)i);
        ++i;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
