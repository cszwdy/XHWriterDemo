//
//  XHWriterDemoTests.m
//  XHWriterDemoTests
//
//  Created by Emiaostein on 2019/10/9.
//  Copyright © 2019 emiaostein. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XHCapturePipline.h"
#import "CaptureItem.h"

@interface XHWriterDemoTests : XCTestCase

@property(nonatomic, strong, nullable) XHCapturePipline *pipline;


@end

@implementation XHWriterDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.pipline = [[XHCapturePipline alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.pipline = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
}

- (void)testAddSameItem {
    CaptureItem *item = [CaptureItem new];
    NSInteger count = [self.pipline addAudioDelegate:@[item, item]];
    
    XCTAssertTrue(count == 1);
}

- (void)testAddDifferentItems {
    CaptureItem *item1 = [CaptureItem new];
    CaptureItem *item2 = [CaptureItem new];
    
    NSUInteger count = [self.pipline addAudioDelegate:@[item1, item2]];
    
    XCTAssertTrue(count == 2);
}

- (void)testRemoveItem {
    CaptureItem *item1 = [CaptureItem new];
    NSUInteger count = 0;
    count = [self.pipline addAudioDelegate:@[item1]];
    
    XCTAssertTrue(count == 1);
    
    count = [self.pipline removeAudioDelegate:@[item1]];
    
    XCTAssertTrue(count == 0);
    
}

- (void)testRemoveNotAddItem {
    CaptureItem *item1 = [CaptureItem new];
    CaptureItem *item2 = [CaptureItem new];
    NSUInteger count = 0;
    count = [self.pipline addAudioDelegate:@[item1]];
    
    XCTAssertTrue(count == 1);
    
    count = [self.pipline removeAudioDelegate:@[item2]];
    
    XCTAssertTrue(count == 1);
}

- (void)testRemoveAll {
    CaptureItem *item1 = [CaptureItem new];
    NSUInteger count = 0;
    count = [self.pipline addAudioDelegate:@[item1]];
    
    XCTAssertTrue(count == 1);
    
    count = [self.pipline removeAllAudioDelegates];
    
    XCTAssertTrue(count == 0);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        CaptureItem *item1 = [CaptureItem new];
        CaptureItem *item2 = [CaptureItem new];
        
        [self.pipline addAudioDelegate:@[item1, item2]];
        
    }];
}

@end
