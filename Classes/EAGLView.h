//
//  EAGLView.h
//  OpenGL
//
//  Created by melfar on 29.08.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "utility.h"

/*
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.
 Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface EAGLView : UIView {
	
@private
	/* The pixel dimensions of the backbuffer */
	GLint backingWidth;
	GLint backingHeight;
	
	EAGLContext *context;
	
	/* OpenGL names for the renderbuffer and framebuffers used to render to this view */
	GLuint viewRenderbuffer, viewFramebuffer;
	
	/* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
	GLuint depthRenderbuffer;
	
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
  
  /* my stuff */
  GLfloat  *vertices;
  GLushort *indices;
  GLfloat  *normals;
  GLfloat  *texcoords;
  
  TriangleHelper* triangle;
  VertexHelper*   vertex;
  
	/* OpenGL name for the sprite texture */
	GLuint spriteTexture;
  CGImageRef spriteImage;
  int counter;
  float bendness;    // amount of deformation
  float crumpleness; // amount of the crumpled paper effect
  int xSlices, ySlices;
  
}

@property NSTimeInterval animationInterval;
@property(nonatomic, assign) CGImageRef spriteImage;

- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (void)prepareTexture;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

@end

