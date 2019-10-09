//
//  AudioPCMRecorder.h
//  YummyApp
//
//  Created by Emiaostein on 2019/3/7.
//  Copyright © 2019 xueersi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RecorderFinishedHandler)(NSString *_Nullable, NSError *_Nullable);

@interface AudioPCMRecorder : NSObject

+ (instancetype)PCMRecorderWithId:(NSString *)Id completed:(RecorderFinishedHandler)handler;
+ (instancetype)WAVRecorderWithName:(NSString *)name completed:(RecorderFinishedHandler)handler;
- (void)appendData:(NSData *)data;
- (void)finished;

@end

NS_ASSUME_NONNULL_END
