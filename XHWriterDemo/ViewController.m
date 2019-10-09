//
//  ViewController.m
//  XHWriterDemo
//
//  Created by Emiaostein on 2019/10/9.
//  Copyright © 2019 emiaostein. All rights reserved.
//

#import "ViewController.h"
#import "XHCapturePipline.h"
#import "CaptureItem.h"
#import "AudioPCMRecorder.h"

@interface ViewController ()<XHCapturePiplineDelegate>

@property(nonatomic, strong, nullable) XHCapturePipline *pipline;
@property(nonatomic, strong, nullable) AudioPCMRecorder *recorder;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.recorder = [AudioPCMRecorder WAVRecorderWithName:@"HelloWorld" completed:^(NSString * _Nullable path, NSError * _Nullable error) {
        NSLog(@"path = %@", path);
    }];
    
    self.pipline = [[XHCapturePipline alloc] init];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"begin");
        CaptureItem *item = [CaptureItem new];
        [self.pipline addAudioDelegate:@[self]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"stop");
        [self.pipline removeAllAudioDelegates];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"begin again");
        CaptureItem *item = [CaptureItem new];
        [self.pipline addAudioDelegate:@[self]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"stop again");
        [self.pipline removeAllAudioDelegates];
        
        [self.recorder finished];
    });
}

- (void)capturePipline:(XHCapturePipline *)capturePipline didOutputAudioSampleBuffer:(CMSampleBufferRef)audioBuffer {
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(audioBuffer);
    size_t totalLengthOut;
     char *data;
    OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, nil, &totalLengthOut, &data);
     NSData *adata = [NSData dataWithBytes:data length:totalLengthOut];
    NSLog(@"status = %d, output size = %zu, data = %lu",(int)status, totalLengthOut, (unsigned long)adata.length);
    [self.recorder appendData:adata];
}


@end
