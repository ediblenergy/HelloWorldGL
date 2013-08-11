#import "Cell.h"
@implementation Cell
@synthesize top,left,width;
-(id)initWithTop:( int)top_ width:( int)width_ left:( int)left_ {
    self = [ super init];
    if(!self) {
        return self;
    }
    self.top = top_;
    self.left = left_;
    self.width = width_;
    return self;
}
@end
