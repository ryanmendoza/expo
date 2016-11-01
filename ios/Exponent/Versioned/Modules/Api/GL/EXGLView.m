#import "EXGLView.h"

#import "RCTJSCExecutor.h"

#import <EXGL.h>


@interface EXGLView ()

@property (nonatomic, weak) EXGLViewManager *viewManager;
@property (nonatomic, strong) GLKViewController *controller;
@property (nonatomic, assign) BOOL onSurfaceCreateCalled;
@property (nonatomic, assign) EXGLContextId exglCtxId;

@end

@implementation EXGLView

RCT_NOT_IMPLEMENTED(- (instancetype)init);

- (instancetype)initWithManager:(EXGLViewManager *)viewManager
{
  if ((self = [super init])) {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    self.drawableMultisample = GLKViewDrawableMultisample4X;
    self.enableSetNeedsDisplay = YES;

    _controller = [[GLKViewController alloc] init];
    _controller.view = self;
    _controller.preferredFramesPerSecond = 60;

    _viewManager = viewManager;

    _onSurfaceCreateCalled = NO;
    _exglCtxId = 0;
  }
  return self;
}

- (void)removeFromSuperview
{
  _controller = nil;
  EXGLContextDestroy(_exglCtxId);
  [super removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
  if (!_onSurfaceCreateCalled) {
    // Can only run on JavaScriptCore
    id<RCTJavaScriptExecutor> executor = [_viewManager.bridge valueForKey:@"javaScriptExecutor"];
    if ([executor isKindOfClass:NSClassFromString(@"RCTJSCExecutor")]) {
      // On JS thread, extract JavaScriptCore context, create EXGL context, call JS callback
      __weak __typeof__(self) weakSelf = self;
      __weak __typeof__(executor) weakExecutor = executor;
      [executor executeBlockOnJavaScriptQueue:^{
        __typeof__(self) self = weakSelf;
        RCTJSCExecutor *executor = weakExecutor;
        if (self && executor) {
          _exglCtxId = EXGLContextCreate(executor.jsContext.JSGlobalContextRef);
          _onSurfaceCreate(@{ @"exglCtxId": @(_exglCtxId) });
        }
      }];
    } else {
      RCTLog(@"EXGL: Can only run on JavaScriptCore!");
    }
    _onSurfaceCreateCalled = YES;
  }

  if (_exglCtxId > 0) { // zero indicates invalid EXGLContextId
    EXGLContextFlush(_exglCtxId);
  }
}

@end
