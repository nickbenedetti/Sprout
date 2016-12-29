//
//  SproutLibTests.m
//  SproutLibTests
//
//  Created by Levi Brown on 10/16/15.
//  Copyright © 2015 Levi Brown. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Sprout.h"

@interface SproutLibTests : XCTestCase

@end

@implementation SproutLibTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStartup100 {
	[[Sprout sharedInstance] startLogging];
	DDLogDebug(@"Testing 123");
}

- (void)testBacktrace100 {
    NSUInteger length = 0;
    NSArray *backtrace = [Sprout trimmedBacktraceSkipping:0 length:length];
    
    XCTAssert(backtrace != nil, @"Backtrace unexpectedly `nil`");
    XCTAssert(backtrace.count == length, @"Backtrace length mismatch (expecting '%d' but got '%d').", (int)length, (int)backtrace.count);
}

- (void)testBacktrace200 {
    NSUInteger length = 1;
    NSArray *backtrace = [Sprout trimmedBacktraceSkipping:0 length:length];
    
    XCTAssert(backtrace != nil, @"Backtrace unexpectedly `nil`");
    XCTAssert(backtrace.count == length, @"Backtrace length mismatch (expecting '%d' but got '%d').", (int)length, (int)backtrace.count);
}

- (void)testBacktrace300 {
    NSUInteger length = 20;
    NSArray *backtrace = [Sprout trimmedBacktraceSkipping:0 length:length];
    
    XCTAssert(backtrace != nil, @"Backtrace unexpectedly `nil`");
    XCTAssert(backtrace.count <= length, @"Backtrace length mismatch (expecting '%d' but got '%d').", (int)length, (int)backtrace.count);
}

- (void)testBacktrace400 {
    NSUInteger length = 200;
    NSArray *backtrace = [Sprout trimmedBacktraceSkipping:0 length:length];
    
    XCTAssert(backtrace != nil, @"Backtrace unexpectedly `nil`");
    XCTAssert(backtrace.count <= length, @"Backtrace length mismatch (expecting at least '%d' but got '%d').", (int)length, (int)backtrace.count);
}

@end
