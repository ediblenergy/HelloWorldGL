//
//  HelloWorldGLTests.m
//  HelloWorldGLTests
//
//  Created by SamK on 8/8/13.
//  Copyright (c) 2013 Samuel Kaufman. All rights reserved.
//

#import "HelloWorldGLTests.h"
#import "Cell.h"
#import "Vertex.h"

@implementation HelloWorldGLTests

- (void)setUp
{
    [super setUp];
    NSLog(@"testo!");
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testExample
{
    Cell *c = [[ Cell alloc ] initWithTop:5 width:7 left:9];
    
    NSLog(@"cell: %@, top: %d", c, c.top);
    STFail(@"Unit tests are not implemented yet in HelloWorldGLTests");
}

@end
