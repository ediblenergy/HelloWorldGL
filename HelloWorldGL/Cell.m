#import "Cell.h"
#import "Vertex.h"

@implementation Cell
@synthesize top,left,width;
@synthesize tl,tr,br,bl;

-(id)initWithTop:( int)top_ width:( int)width_ left:( int)left_ {
    self = [ super init];
    if(!self) {
        return self;
    }
    self.top = top_;
    self.left = left_;
    self.width = width_;
    self.z = 0;
    self.tl = [[ Vertex alloc ] initWithX:self.left y:self.top z:self.z ];
    self.tr = [[ Vertex alloc ] initWithX:self.left+self.width y:self.top z:self.z ];
    self.br = [[ Vertex alloc ] initWithX:self.left+self.width y:self.top+self.width z:self.z ];
    self.bl = [[ Vertex alloc ] initWithX:self.left y:self.top+self.width z:self.z ];
    return self;
}


@end
