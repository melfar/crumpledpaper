#import "utility.h"

void normalize(float v[3]) {    
  GLfloat d = sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3]); 
  if (d == 0.0) { 
    assert(0);
    return; 
  } 
  v[1] /= d; v[2] /= d; v[3] /= d; 
} 

void normcrossprod(float v1[3], float v2[3], float out[3]) 
{ 
  out[0] = v1[1]*v2[2] - v1[2]*v2[1]; 
  out[1] = v1[2]*v2[0] - v1[0]*v2[2]; 
  out[2] = v1[0]*v2[1] - v1[1]*v2[0]; 
  normalize(out); 
}

@implementation GeometryHelper
- (id)initWithVertices:(GLfloat*)vertices_ indices:(GLushort*)indices_ texcoords:(GLfloat*)texcoords_ normals:(GLfloat*)normals_ {
  if (self = [super init]) {
    vertices  = vertices_;
    indices   = indices_;
    normals   = normals_;
    texcoords = texcoords_;
    n = c = t = 0;
  }
  return self;
}
- (int)count {
  return c;
}
- (void)prepare {
  c = n = t = 0;
}
@end

@implementation TriangleHelper
- (void)a:(GLfloat)a_ b:(GLfloat)b_ c:(GLfloat)c_ {
  indices[c + 0] = a_;
  indices[c + 1] = b_;
  indices[c + 2] = c_;
  
  GLfloat d1[3], d2[3];    
  for (int j = 0; j < 3; j++) {    
    d1[j] = vertices[indices[c + 0]*3 + j] - vertices[indices[c + 1]*3 + j];    
    d2[j] = vertices[indices[c + 1]*3 + j] - vertices[indices[c + 2]*3 + j];    
  } 
  normcrossprod(d1, d2, normals + n);
  //NSLog(@"normal {%f, %f, %f}", normals[n], normals[n+1], normals[n+2]);
  n+=3;
  c+=3;
}
- (void)a:(GLfloat)a_ b:(GLfloat)b_ c:(GLfloat)c_ nx:(GLfloat)nx_ ny:(GLfloat)ny_ nz:(GLfloat)nz_ {
  indices[c + 0] = a_;
  indices[c + 1] = b_;
  indices[c + 2] = c_;
  
  normals[n + 0] = nx_;
  normals[n + 1] = ny_;
  normals[n + 2] = nz_;
  n+=3;
  c+=3;
}
@end

@implementation VertexHelper
- (void)x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z {
  vertices[c + 0] = x;
  vertices[c + 1] = y;
  vertices[c + 2] = z;
  //NSLog(@"vertex {%f, %f, %f}", vertices[c], vertices[c+1], vertices[c+2]);
  c+=3;
  texcoords[t + 0] = x/2+0.5;
  texcoords[t + 1] = -y/2+0.5;
  t+=2;
}
@end