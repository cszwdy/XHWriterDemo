//
//  XHCapturePipline.h
//  XHWriterDemo
//
//  Created by Emiaostein on 2019/10/9.
//  Copyright © 2019 emiaostein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XHCapturePiplineDelegate;


@interface XHCapturePipline : NSObject

/// These methods are synchronous
- (NSUInteger)addAudioDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)audioDelegates;
- (NSUInteger)removeAudioDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)audioDelegates;
- (NSUInteger)removeAllAudioDelegates;
- (NSUInteger)addVideoDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)videoDelegates;
- (NSUInteger)removeVideoDelegate:(NSArray<NSObject<XHCapturePiplineDelegate> *> *_Nonnull)videoDelegates;
- (NSUInteger)removeAllVideoDelegates;


@end


@protocol XHCapturePiplineDelegate <NSObject>

- (void)capturePipline:(XHCapturePipline *)capturePipline
didOutputAudioSampleBuffer:(CMSampleBufferRef)audioBuffer;

- (void)capturePipline:(XHCapturePipline *)capturePipline
didOutputVideoSampleBuffer:(CMSampleBufferRef)audioBuffer;

@end

NS_ASSUME_NONNULL_END
