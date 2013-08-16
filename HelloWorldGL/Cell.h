@class Vertex;

@interface Cell : NSObject {
    NSArray *vertices;
}


@property NSInteger top;
@property NSInteger left;
@property NSInteger width;
@property NSInteger z;
@property Vertex *tl;
@property Vertex *tr;
@property Vertex *bl;
@property Vertex *br;



-(id)initWithTop:( int)top_ width:(int)width_ left:( int)left_;

@end
