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
@property(nonatomic, strong, nullable) AVAudioConverter *converter;
@property(nonatomic, strong, nullable) AVAudioFormat *toFormat;
@property(nonatomic, strong, nullable) AVAudioFormat *fromFormat;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVAudioFormat *from = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:1];
    AVAudioFormat *to = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:16000 channels:1];
    self.converter = [[AVAudioConverter alloc] initFromFormat:from toFormat:to];
    self.toFormat = to;
    self.fromFormat = from;
    
    self.recorder = [AudioPCMRecorder WAVRecorderWithName:@"HelloWorld" completed:^(NSString * _Nullable path, NSError * _Nullable error) {
        NSLog(@"path = %@", path);
    }];
    
    self.pipline = [[XHCapturePipline alloc] init];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"begin");
//        CaptureItem *item = [CaptureItem new];
        [self.pipline addAudioDelegate:@[self]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"stop");
        [self.pipline removeAllAudioDelegates];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"begin again");
//        CaptureItem *item = [CaptureItem new];
        [self.pipline addAudioDelegate:@[self]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"stop again");
        [self.pipline removeAllAudioDelegates];
        
        [self.recorder finished];
    });
}

- (void)capturePipline:(XHCapturePipline *)capturePipline didOutputAudioSampleBuffer:(CMSampleBufferRef)audioBuffer {
    CMFormatDescriptionRef formatDes = CMSampleBufferGetFormatDescription(audioBuffer);
    size_t bytesSize = CMSampleBufferGetTotalSampleSize(audioBuffer); // 2048
    const AudioStreamBasicDescription *des =  CMAudioFormatDescriptionGetStreamBasicDescription(formatDes);
    size_t packets = bytesSize / des->mBytesPerPacket;
    size_t frames = packets * des->mFramesPerPacket;
    NSLog(@"sampleRate = %f, frame = %zu, channels = %u", des->mSampleRate, frames, (unsigned int)des->mChannelsPerFrame);
    
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(audioBuffer);
    size_t totalLengthOut;
     char *data;
    OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, nil, &totalLengthOut, &data);
    
    
     NSData *adata = [NSData dataWithBytes:data length:totalLengthOut];
//    NSLog(@"status = %d, output size = %zu, data = %lu",(int)status, totalLengthOut, (unsigned long)adata.length);
    
    AVAudioPCMBuffer *tobuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.toFormat frameCapacity:(AVAudioFrameCount)frames];
    
    AVAudioPCMBuffer *fromBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.fromFormat frameCapacity:(AVAudioFrameCount)frames];
    fromBuffer.frameLength = (AVAudioFrameCount)frames;
    
    
    NSError *error;
    [self.converter convertToBuffer:tobuffer error:&error withInputFromBlock:^AVAudioBuffer * _Nullable(AVAudioPacketCount inNumberOfPackets, AVAudioConverterInputStatus * _Nonnull outStatus) {
        *outStatus = AVAudioConverterInputStatus_HaveData;
        return [[AVAudioBuffer alloc] init]
    }];
    
    [self.recorder appendData:adata];
}


@end
