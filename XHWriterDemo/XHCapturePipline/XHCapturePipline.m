//
//  XHCapturePipline.m
//  XHWriterDemo
//
//  Created by Emiaostein on 2019/10/9.
//  Copyright © 2019 emiaostein. All rights reserved.
//

#import "XHCapturePipline.h"

@interface XHCapturePipline () <AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, copy) NSString *audioDelegateLockToken;
@property (nonatomic, copy) NSString *videoDelegateLockToken;
@property(nonatomic, strong, nullable) NSMutableSet<NSObject<XHCapturePiplineDelegate> *> *audioDelegates;
@property(nonatomic, strong, nullable) NSMutableSet<NSObject<XHCapturePiplineDelegate> *> *videoDelegates;

@property(nonatomic, strong, nullable) AVCaptureSession *captureSession;
@property(nonatomic, assign) BOOL audioOutputing;
@property(nonatomic, strong, nullable) AVCaptureDeviceInput *audioInput;
@property(nonatomic, strong, nullable) AVCaptureAudioDataOutput *audioOutput;
@property(nonatomic, strong, nullable) AVCaptureConnection *audioConnection;
@property(nonatomic, assign) BOOL videoOutputing;
@property(nonatomic, strong, nullable) AVCaptureDeviceInput *videoInput;
@property(nonatomic, strong, nullable) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong, nullable) AVCaptureConnection *videoConnection;




@end

@implementation XHCapturePipline

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioDelegateLockToken = @"audioDelegateLockToken";
        self.videoDelegateLockToken = @"videoDelegateLockToken";
        self.audioDelegates = [[NSMutableSet alloc] init];
        self.videoDelegates = [[NSMutableSet alloc] init];
        self.audioOutputing = NO;
        self.videoOutputing = NO;
        [self p_setupCaptureSession];
    }
    return self;
}

/// These methods are synchronous
- (NSUInteger)addAudioDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)audioDelegates {
    NSUInteger count = 0;
    @synchronized (self.audioDelegateLockToken) {
        NSUInteger old = self.audioDelegates.count;
        [self.audioDelegates addObjectsFromArray:audioDelegates];
        count = self.audioDelegates.count;
        
        if (old <= 0 && count > 0 && !self.audioOutputing) {
            // start audio output
            NSLog(@"will start audio output");
            [self p_startAudioOutput];
        }
    }
    return count;
    
}

- (NSUInteger)removeAudioDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)audioDelegates {
    NSUInteger count = 0;
    @synchronized (self.audioDelegateLockToken) {
        NSUInteger old = self.audioDelegates.count;
        NSSet *set = [NSSet setWithArray:audioDelegates];
        for (NSObject<XHCapturePiplineDelegate> *item in set) {
            [self.audioDelegates removeObject:item];
        }
        count = self.audioDelegates.count;
        
        if (old > 0 && count == 0 && self.audioOutputing) {
            // stop audio output
        }
    }
    return count;
}

- (NSUInteger)removeAllAudioDelegates {
    NSUInteger count = 0;
    @synchronized (self.audioDelegateLockToken) {
        [self.audioDelegates removeAllObjects];
        count = self.audioDelegates.count;
        if (self.audioOutputing) {
            [self p_stopAudioOutput];
        }
    }
    return count;
}

- (NSUInteger)addVideoDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)videoDelegates {
    NSUInteger count = 0;
    @synchronized (self.videoDelegateLockToken) {
        [self.videoDelegates addObjectsFromArray:videoDelegates];
        count = self.videoDelegates.count;
    }
    return count;
}

- (NSUInteger)removeVideoDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)videoDelegates {
    NSUInteger count = 0;
    @synchronized (self.videoDelegateLockToken) {
        NSSet *set = [NSSet setWithArray:videoDelegates];
        for (NSObject<XHCapturePiplineDelegate> *item in set) {
            [self.videoDelegates removeObject:item];
        }
        count = self.videoDelegates.count;
    }
    return count;
}

- (NSUInteger)removeAllVideoDelegates {
    NSUInteger count = 0;
    @synchronized (self.videoDelegateLockToken) {
        [self.videoDelegates removeAllObjects];
        count = self.videoDelegates.count;
    }
    return count;
}


#pragma mark - Private methods

- (void)p_setupCaptureSession {
    if (self.captureSession) {
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // Init audio microphone input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    if ( [self.captureSession canAddInput:audioIn] ) {
        self.audioInput = audioIn;
    }
    
    // Init audio output
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    // Put audio on its own queue to ensure that our video processing doesn't cause us to drop audio
    dispatch_queue_t audioCaptureQueue = dispatch_queue_create( "com.apple.sample.capturepipeline.audio", DISPATCH_QUEUE_SERIAL );
    [audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
    if ( [self.captureSession canAddOutput:audioOut] ) {
        self.audioOutput = audioOut;
    }
}

- (void)p_startAudioOutput {
    if (self.audioOutputing) {
        return;
    }
    
    self.audioOutputing = YES;
    
    if (self.audioConnection) {
        self.audioConnection.enabled = YES;
    }
    
    if ([self.captureSession canAddInput:self.audioInput]) {
        [self.captureSession addInput:self.audioInput];
    }
    
    if ([self.captureSession canAddOutput:self.audioOutput]) {
        [self.captureSession addOutput:self.audioOutput];
    }
    
    self.audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    
    [self.captureSession startRunning];
    
    
}

- (void)p_stopAudioOutput {
    if (!self.audioOutputing) {
        return;
    }
    self.audioOutputing = NO;
    self.audioConnection.enabled = NO;
    
    
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (connection == self.audioConnection) {
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        if (blockBuffer == NULL) {
            return;
        } else {
            
            @synchronized (self.audioDelegateLockToken) {
                for (NSObject<XHCapturePiplineDelegate>* item in self.audioDelegates) {
                    if ([item respondsToSelector:@selector(capturePipline:didOutputAudioSampleBuffer:)]) {
                        [item capturePipline:self didOutputAudioSampleBuffer:sampleBuffer];
                    }
                }
                
            }
        }
    }
    
    
}

@end
