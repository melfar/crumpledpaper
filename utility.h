/*
 *  utility.h
 *  OpenGL
 *
 *  Created by melfar on 04.09.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

void normalize(float v[3]);
void normcrossprod(float v1[3], float v2[3], float out[3]);

@interface GeometryHelper : NSObject
{
  GLfloat  *vertices;
  GLushort *indices;
  GLfloat  *normals;
  GLfloat  *texcoords;
  int n, c, t;
}

- (id)initWithVertices:(GLfloat*)vertices indices:(GLushort*)indices texcoords:(GLfloat*)texcoords normals:(GLfloat*)normals;
- (void)prepare;
- (int)count;
@end

@interface VertexHelper : GeometryHelper
{
}
- (void)x:(GLfloat)x_ y:(GLfloat)y_ z:(GLfloat)z_;
@end

@interface TriangleHelper : GeometryHelper
{
}
- (void)a:(GLfloat)a_ b:(GLfloat)b_ c:(GLfloat)c_;
- (void)a:(GLfloat)a_ b:(GLfloat)b_ c:(GLfloat)c_ nx:(GLfloat)nx_ ny:(GLfloat)ny_ nz:(GLfloat)nz_;
@end
