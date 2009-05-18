//
//  EAGLView.m
//  OpenGL
//
//  Created by melfar on 29.08.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "utility.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize spriteImage;


// You must implement this
+ (Class)layerClass {
	return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
  
	if ((self = [super initWithCoder:coder])) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}
		
		animationInterval = 1.0 / 60.0;
    
    vertices  = malloc(100000 * sizeof(GLfloat));
    indices   = malloc(100000 * sizeof(GLushort));
    normals   = malloc(100000 * sizeof(GLfloat));
    texcoords = malloc(100000 * sizeof(GLfloat));
    
    triangle = [[TriangleHelper alloc] initWithVertices:vertices indices:indices texcoords:texcoords normals:normals];
    vertex   = [[VertexHelper alloc] initWithVertices:vertices indices:indices texcoords:texcoords normals:normals];
    
    counter = 0;
    xSlices = 11;
    ySlices = 15;
    
    [self prepareTexture];
  }
	return self;
}

- (void)prepareTexture {
  // texture
  CGContextRef spriteContext;
  GLubyte *spriteData;
  size_t	width, height;
  
  spriteImage = [UIImage imageNamed:@"twitterific.png"].CGImage;  
  width = CGImageGetWidth(spriteImage);
  height = CGImageGetHeight(spriteImage);
  width = height = 512;
  if(spriteImage)
  {
    spriteData = (GLubyte *) calloc(width * height, 4);
    spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
    CGContextRelease(spriteContext);
    
    glGenTextures(1, &spriteTexture);
    glBindTexture(GL_TEXTURE_2D, spriteTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glEnable(GL_TEXTURE_2D);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);    
  }  
}

- (void)setOrientation:(UIInterfaceOrientation)orientation {
  if (orientation ==  UIInterfaceOrientationPortrait) {
    xSlices = 11, ySlices = 15;
  } else {
    xSlices = 15, ySlices = 11;
  }
}

- (void)drawView {
  srand(10);
  
  if (counter == 0) {
    bendness = 0;    // amount of deformation
    crumpleness = 0; // amount of the crumpled paper effect
  }
  
  counter++;
  if (counter > 1 && counter < 80) {
    // small pause
    return;
  }
 
  bendness += 0.00009 * counter*counter*counter*0.000002; 
  crumpleness += 0.01 * counter*counter*counter*0.000005;
  
  [vertex prepare];
  for (int i = 0; i < xSlices; i++) {
    for (int j = 0; j < ySlices; j++) {
      float distance = sqrt(2.0*2.0*(i-xSlices/2)*(i-xSlices/2) + 3.0*3.0*(j-ySlices/2)*(j-ySlices/2));
      [vertex  x: i*0.2-1  y: j*0.2-1.5  z: -1.5-distance*distance*bendness-crumpleness*rand()/RAND_MAX];
    }
  }
  
  // indices and normals
  [triangle prepare];
  for (int i = 0; i < xSlices - 1; i++) {
    for (int j = 0; j < ySlices - 1; j++) {
      if (i%2 == 0) {
        if (j%2 == 0) {
          [triangle a: j+ySlices*i      b: j+ySlices*i+1      c: j+ySlices*(i+1)];
          [triangle a: j+ySlices*(i+1)  b: j+ySlices*i+1      c: j+ySlices*(i+1)+1];
        } else {
          [triangle a: j+ySlices*i      b: j+ySlices*(i+1)+1  c: j+ySlices*(i+1)];
          [triangle a: j+ySlices*i      b: j+ySlices*i+1      c: j+ySlices*(i+1)+1];
        }
      } else {
        if (j%2 == 0) {
          [triangle a: j+ySlices*i      b: j+ySlices*i+1      c: j+ySlices*(i+1)+1];
          [triangle a: j+ySlices*(i+1)  b: j+ySlices*i        c: j+ySlices*(i+1)+1];
        } else {
          [triangle a: j+ySlices*i      b: j+ySlices*i+1      c: j+ySlices*(i+1)];
          [triangle a: j+ySlices*(i+1)  b: j+ySlices*i+1      c: j+ySlices*(i+1)+1];
        }
      }
    }
  }  
  
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
  glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
  glFrustumf(-1.0, 1.0, -1.0, 1.0, 1.5, 20.0);
	glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
  // draw
	glVertexPointer(3, GL_FLOAT, 0, vertices);
  glNormalPointer(GL_FLOAT, 0, normals);
	glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glShadeModel(GL_FLAT);
  
  // lighting
  GLfloat lmodel_ambient[] = { 0.9, 0.9, 0.9, 1.0 };
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lmodel_ambient);  
  
  GLfloat mat_specular[]   = { 1.0, 1.0, 1.0, 1.0 }; 
  GLfloat mat_shininess[]  = { 50.0 }; 
  GLfloat light_position[] = { 0.0, 0.0, -2.0, 0.0 }; 
  GLfloat mat_ambient[]    = { 0.5, 0.5, 0.5, 1.0 };
  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular); 
  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess); 
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mat_ambient); 
  glLightfv(GL_LIGHT0, GL_POSITION, light_position); 
  glEnable(GL_LIGHTING); 
  glEnable(GL_LIGHT0); 
  glDepthFunc(GL_LEQUAL); 
  glEnable(GL_DEPTH_TEST);  
  
  if (counter < 180) {
    glDrawElements(GL_TRIANGLES, [triangle count], GL_UNSIGNED_SHORT, indices);
  } else {
    [self stopAnimation];
  }
  
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}


- (BOOL)createFramebuffer {
	
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	if (USE_DEPTH_BUFFER) {
		glGenRenderbuffersOES(1, &depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	}
  
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}


- (void)destroyFramebuffer {
	
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (void)startAnimation {
  counter = 0;
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
	self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
	[animationTimer invalidate];
	animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
	
	animationInterval = interval;
	if (animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}


- (void)dealloc {
	
	[self stopAnimation];
	
	if ([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];	
  free(vertices);
  free(normals);
  free(indices);
  free(texcoords);
  [triangle release];
  [vertex release];
  
	[super dealloc];
}

@end



