//
//  EAGLView.h
//  OpenGLES_iPhone
//
//  Created by mmalc Crawford on 11/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView {
}

@property (nonatomic, strong) EAGLContext               *context;
@property (nonatomic, readonly) GLuint                  defaultFramebuffer;
@property (nonatomic, readonly) GLuint                  colorRenderbuffer;
@property (nonatomic, readonly) GLint                   framebufferWidth;
@property (nonatomic, readonly) GLint                   framebufferHeight;

@property (nonatomic, strong) IBOutlet UIButton        *infoButton;
@property (nonatomic, strong) IBOutlet UIButton        *expandButton;
@property (nonatomic, strong) UILabel                  *nameLabel;
@property (nonatomic, weak) dispatch_queue_t           openglesQueue;

- (void)setFramebuffer;
- (void)deleteFramebuffer;
- (BOOL)presentFramebuffer;
- (UIImage*) snapshot;

@end
