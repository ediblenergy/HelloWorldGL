//
//  OpenGLView.h
//  HelloWorldGL
//
//  Created by SamK on 8/8/13.
//  Copyright (c) 2013 Samuel Kaufman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
@interface OpenGLView : UIView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _colorSlot;
    GLuint _positionSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    float _currentRotation;
}

@end
