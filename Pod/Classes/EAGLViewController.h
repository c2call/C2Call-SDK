//
//  GLAppViewController.h
//  GLApp
//
//  Created by Michael Knecht on 23.03.11.
//  Copyright 2011 Actai Networks GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface EAGLViewController : UIViewController {
}

@property (nonatomic, strong) EAGLContext                   *context;
@property (nonatomic) int                                   imageWidth;
@property (nonatomic) int                                   imageHeight;
@property (nonatomic) int                                   rotate;
@property (readonly, nonatomic) dispatch_queue_t            openglesQueue;
@property BOOL                                              reset;
@property (atomic) BOOL                                     background;
@property (nonatomic) CGFloat                               imageAspectReverse;
@property (nonatomic) CGFloat                               imageAspect;
@property (nonatomic) unsigned long                         ssrc;
@property BOOL                                              active;
@property (nonatomic)  CFAbsoluteTime                       lastFrameTimestamp;

-(void) updateImageAspectWithWidth:(int) width andHeight:(int) heigth;
-(void) setTextureData:(NSData *)data withWidth:(int) width andHeight:(int) height;
-(void) dispose;
-(UIImage *) getCurrentScreen;
-(IBAction)toggleExpandCollapse:(id)sender;

@end
