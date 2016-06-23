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

@interface HYViewController ()
{
    NSMutableArray *_array;
}

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    for (NSInteger index = 0; index < 1; ++index) {
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            [[HYImageDownloadManager sharedManager] downloadImageWithURL:@"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2047158/beerhenge.jpg" options:HYWebImageOptionAllowInvalidSSLCertificates progressBlock:^(double progress) {
//                
//            } completeBlock:^(UIImage * _Nullable image, HYWebImageCompleteType type, NSError * _Nullable error) {
//                
//            }];
//        });
//    }
    
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
            
            HYImageDownloadOperation *op = [[HYImageDownloadManager sharedManager] downloadImageWithURL:@"http://img6.cache.netease.com/news/2016/6/23/201606230739557c16b.jpg" options:HYWebImageOptionAllowInvalidSSLCertificates | HYWebImageOptionProgressive progressBlock:^(double progress) {
                
            } completeBlock:^(HYImage * _Nullable image, HYWebImageCompleteType type, HYWebImageFrom from, NSError * _Nullable error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (type == HYWebImageCompleteTypeFinish || type == HYWebImageCompleteTypeProgress) {
                        
                        self.view.layer.contents = (id)image.singleImage.CGImage;
                        
                        static NSInteger i = 1;
                        
                        NSLog(@"%ld Finish", (long)i);
                        
                        ++i;
                    }
                    
                });
            }];
            
            //[_array addObject:op];
        });
    }
}

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
