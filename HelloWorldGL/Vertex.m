#import "Vertex.h"

@implementation Vertex

@synthesize x,y,z;


- (id) initWithX:(NSInteger)x_ y:(NSInteger)y_ z:(NSInteger)z_ {
    self = [ super init ];
    if( ! self ) {
        return self;
    }
    self.x = x_;
    self.y = y_;
    self.z = z_;
    return self;
}

@end