//
//  OpenGLView.m
//  HelloWorldGL
//
//  Created by SamK on 8/8/13.
//  Copyright (c) 2013 Samuel Kaufman. All rights reserved.
//
// Add to top of file
#import "CC3GLMatrix.h"
#import "OpenGLView.h"

@implementation OpenGLView

// Add new method before init
- (void)setupDisplayLink {
    CADisplayLink* displayLink = [
        CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog( @"initWithFrame");
    self = [super initWithFrame:frame];
    if( !self ) {
        return self;
    }
    
    [ self setupLayer ];
    [ self setupContext ];
    [ self setupRenderBuffer ];
    [ self setupFrameBuffer ];
    [ self compileShaders ];
    [ self setupVBOs ];
    [ self setupDisplayLink ];
    return self;
}


+ (Class) layerClass {
        return [CAEAGLLayer class];
}

- (void) setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void) setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI: api];
    NSLog(@"setupContext");
    if(! _context ) {
        NSLog(@"Failed to initialize OpenGLES context");
        exit(1);
    }

    if(![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void) setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void) setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers( 1, &framebuffer );
    glBindFramebuffer( GL_FRAMEBUFFER, framebuffer );
    glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer );
}




- (GLuint)compileShader: (NSString*)shaderName withType:(GLenum)shaderType {
    NSString *shaderPath = [
        [ NSBundle mainBundle ] 
        pathForResource: shaderName 
                 ofType: @"glsl"
    ];
    NSError *error;
    NSString *shaderString = [
        NSString stringWithContentsOfFile:shaderPath
                                 encoding:NSUTF8StringEncoding
                                    error:&error
                                    ];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
  GLuint shaderHandle = glCreateShader(shaderType);    
 
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
 
    glCompileShader(shaderHandle);
 
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
 
    return shaderHandle;
}

- (void)compileShaders {
    
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];

    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
 
}

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {1, 1, 1, 1}}
};

const GLubyte Indices[] = {
    0,1,2,
    2,3,0
};
typedef struct {
    float x;
    float y;
    float z;
} CelluloVector;

CelluloVector* createCelluloVector(float x, float y, float z) {
    CelluloVector* v = malloc(sizeof( CelluloVector));
    v->x = x;
    v->y = y;
    v->z = z;
    return v;
}

typedef struct CelluloBox {
    float _top;
    float _left;
    float _diameter;
    CelluloVector* ( *topLeft )( struct CelluloBox* );
    CelluloVector* ( *topRight )( struct CelluloBox* );
    CelluloVector* ( *bottomLeft )( struct CelluloBox* );
    CelluloVector* ( *bottomRight )( struct CelluloBox* );
    Vertex*        ( *vertices )( struct CelluloBox* );
} CelluloBox;



CelluloVector* _CelluloBoxTopLeft( CelluloBox* cb ) {
    return createCelluloVector( cb->_left, cb->_top, 0 );
}

CelluloVector* _CelluloBoxTopRight( CelluloBox* cb ) {
    return createCelluloVector( cb->_left + cb->_diameter, cb->_top, 0 );
}

CelluloVector* _CelluloBoxBottomRight( CelluloBox* cb ) {
    return createCelluloVector( cb->_left + cb->_diameter, cb->_top + cb->_diameter, 0 );
}
    
CelluloVector* _CelluloBoxBottomLeft( CelluloBox* cb ) {
    return createCelluloVector( cb->_left, cb->_top + cb->_diameter, 0 );
}

Vertex* _CelluloBoxVertices( CelluloBox* cb ) {
    Vertex *vertex = (Vertex*)malloc(sizeof(Vertex)*4);
//    (words*)malloc(sizeof(words) * 100);
    CelluloVector* tl = cb->topLeft(cb);
    CelluloVector* tr = cb->topRight(cb);
    CelluloVector* br = cb->bottomRight(cb);
    CelluloVector* bl = cb->bottomLeft(cb);
    vertex[0] = (Vertex) {{tl->x,tl->y,tl->z},{1, 0, 0, 1}};
    vertex[1] = (Vertex) {{tr->x,tr->y,tr->z},{1, 0, 0, 1}};
    vertex[2] = (Vertex) {{br->x,br->y,br->z},{1, 0, 0, 1}};
    vertex[3] = (Vertex) {{bl->x,bl->y,bl->z},{1, 0, 0, 1}};
    return vertex;
}
CelluloBox* createCelluloBox( float l, float t, float diameter ) {
    CelluloBox* cb = malloc(sizeof(CelluloBox));
    cb->_top = t;
    cb->_left = l;
    cb->_diameter = diameter;
    cb->topLeft = &_CelluloBoxTopLeft;
    cb->topRight = &_CelluloBoxTopRight;
    cb->bottomRight = &_CelluloBoxBottomRight;
    cb->bottomLeft = &_CelluloBoxBottomLeft;
    cb->vertices = &_CelluloBoxVertices;
    return cb;
}

- (void)setupVBOs {
    
    CelluloBox* cb = createCelluloBox(-1.0, 1.0,2.0);
    CelluloVector* tl  = cb->topLeft(cb);
//    Vertex* vertexes =
    
    Vertex* vertex = cb->vertices(cb);
    NSLog(@"cb->topLeft = (%f,%f)", tl->x, tl->y );
    NSLog(@"vertexes[2] = %f",vertex->Color);
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (void) render:(CADisplayLink*)displayLink {
    glClearColor(0,0,0,1);
    glClear( GL_COLOR_BUFFER_BIT );
    
    // Add to render, right before the call to glViewport
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection 
        populateFromFrustumLeft:-2
                       andRight:2
                      andBottom:-h/2
                         andTop:h/2
                        andNear:4
                         andFar:10
    ];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);

    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);

    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    glVertexAttribPointer(
                          _positionSlot,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Vertex),
                          0
                          );
    
    glVertexAttribPointer(
                          _colorSlot,
                          4,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Vertex),
                          (GLvoid*) (sizeof(float) * 3)
                          );
    
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [ _context presentRenderbuffer: GL_RENDERBUFFER ];
    
 
// Modify vertices so they are within projection near/far planes
}

@end
