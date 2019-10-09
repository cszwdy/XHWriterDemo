//
//  AudioPCMRecorder.m
//  YummyApp
//
//  Created by Emiaostein on 2019/3/7.
//  Copyright © 2019 xueersi. All rights reserved.
//

#import "AudioPCMRecorder.h"

@interface AudioPCMRecorder ()

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *savedPath;
@property(nonatomic, assign) BOOL isWav;
@property(nonatomic, copy) RecorderFinishedHandler handler;
@property(nonatomic, strong) NSOutputStream *stream;
@property(nonatomic, assign) NSInteger dataCount;
@property(nonatomic, assign) BOOL didFinished;
@end

@implementation AudioPCMRecorder

+ (instancetype)PCMRecorderWithId:(NSString *)name completed:(RecorderFinishedHandler)handler {
    return [self recorderWithWav:NO name:name completed:handler];
}

+ (instancetype)WAVRecorderWithName:(NSString *)name completed:(RecorderFinishedHandler)handler {
    return [self recorderWithWav:YES name:name completed:handler];
}

+ (instancetype)recorderWithWav:(BOOL)isWav name:(NSString *)name completed:(RecorderFinishedHandler)handler {
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    if (isWav) {
        path = [path stringByAppendingPathExtension:@"wav"];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == YES) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    
    AudioPCMRecorder *recorder = [[AudioPCMRecorder alloc] init];
    recorder.name = name;
    recorder.isWav = isWav;
    recorder.handler = handler;
    recorder.savedPath = path;
    recorder.dataCount = 0;
    recorder.didFinished = NO;
    recorder.stream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
    [recorder.stream open];
    
//    NSData *d = aWriteWavFileHeader(0, 0+36, 16000, 1, 32000);
//    [recorder.stream write:d.bytes maxLength:d.length];
    
    return recorder;
}

- (void)appendData:(NSData *)data {
    if (data != nil && data.length > 0) {
        _dataCount += data.length;
        [_stream write:data.bytes maxLength:data.length];
    }
}

- (void)finished {
    if (_didFinished == YES) {return;}
    _didFinished = YES;
    if (_isWav) {
        NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:_savedPath];
        [handle seekToFileOffset:0];
        NSData *header = aWriteWavFileHeader(_dataCount, _dataCount+36, 44100, 1, 32000);
        [handle writeData:header];
    }
    
    [_stream close];
    _handler(_savedPath, NULL);
}

NSData* aWriteWavFileHeader(long totalAudioLen, long totalDataLen, long longSampleRate,int channels, long byteRate)
{
    Byte  header[44];
    header[0] = 'R';  // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    header[4] = (Byte) (totalDataLen & 0xff);  //file-size (equals file-size - 8)
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    header[8] = 'W';  // Mark it as type "WAVE"
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';  // Mark the format section 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    header[16] = 16;   // 4 bytes: size of 'fmt ' chunk, Length of format data.  Always 16
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;  // format = 1 ,Wave type PCM
    header[21] = 0;
    header[22] = (Byte) channels;  // channels
    header[23] = 0;
    header[24] = (Byte) (longSampleRate & 0xff);
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    header[28] = (Byte) (byteRate & 0xff);
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    header[32] = (Byte) (2 * 16 / 8); // block align
    header[33] = 0;
    header[34] = 16; // bits per sample
    header[35] = 0;
    header[36] = 'd'; //"data" marker
    header[37] = 'a';
    header[38] = 't';
    header[39] = 'a';
    header[40] = (Byte) (totalAudioLen & 0xff);  //data-size (equals file-size - 44).
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    return [[NSData alloc] initWithBytes:header length:44];;
}

@end
