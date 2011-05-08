#import "EditView.h"

#import <QuartzCore/QuartzCore.h>

#include "../ui_helper.h"

@implementation EditView
- (void)handleTapGesture:(UITapGestureRecognizer *)r
{
  extern bool g_want_guide_lines;
  g_want_guide_lines=!g_want_guide_lines;
  [self setNeedsDisplay];
  
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)r
{
  if (m_curImage)
  {
    CGPoint p = [r translationInView:self];
    if ([r numberOfTouches]==2)
    {
      m_curImage->aspect *= pow(2.0,p.y*0.03);
    }
    else
    {
      m_curImage->xoffs += p.x;
      m_curImage->yoffs += p.y;
    }
    [r setTranslation:CGPointMake(0,0) inView:self];
    [self setNeedsDisplay];
    
  }
}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)r
{
  if (m_curImage)
  {
    m_curImage->zoom *= pow(2.0, r.scale-1.0);

    r.scale=1.0;
    [self setNeedsDisplay];
    
  }
}
-(id) initWithName:(NSString*)name data:(id)value
{
  if ((self = [super init]))
  {
    CGRect b = [self bounds];
    b.origin.y -= 70.0;
    [self setBounds:b];
    
    m_curImage = value && [value isKindOfClass:[ImageFieldRec class]] ? [value retain] : nil; 
    [m_curImage getImage];
    self.backgroundColor = [UIColor whiteColor];

    //self.multipleTouchEnabled=true;
    UITapGestureRecognizer *tap;
//    [self addGestureRecognizer:[[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotGesture:)] autorelease]];
    [self addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)] autorelease]];
    [self addGestureRecognizer:(tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)] autorelease])];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:[[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)] autorelease]];
    
    int lh = 30;
    int w= 320;//[self frame].size.width;
    int dp=((w*100)/320);
    mklabel(self,1000,  3,0,dp-5,lh-3, @"Field name:");
    mkedit(self, 1001,  dp, 1, w-dp-3,lh, name).clearButtonMode=UITextFieldViewModeUnlessEditing;

    CGRect er = CGRectMake(3,lh+4,w-6,480 - lh-4 - 20);
    
    {
      UITextView *obj = [[UITextView alloc] init];
      obj.tag = 1002;
      obj.frame = er;
      obj.layer.borderWidth = 1;
      obj.layer.borderColor = [[UIColor grayColor] CGColor];
      if (value && [value isKindOfClass:[NSString class]])
      {
        obj.text = value;
      }
      if (m_curImage) obj.hidden = true;
      [self addSubview:[obj autorelease]];
    }   
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  if (m_curImage)
  {
    CGRect fr=[self bounds];
    CGRect r2 = [[self viewWithTag:1002] frame];
    fr.origin.y += r2.origin.y;
    fr.size.height -= r2.origin.y;
    
    CGRect tr=CGRectMake(fr.origin.x+2,fr.origin.y+2,fr.size.width-4,fr.size.height-4);
    [m_curImage drawInRect:tr];
  }
}

-(void)setImage:(ImageFieldRec *)image
{
  [image retain];
  [m_curImage release];
  m_curImage=image;
  [image getImage];
  
  UITextField *f = (UITextField*)[self viewWithTag:1002];
  if (f) f.hidden=!!m_curImage;
  [self setNeedsDisplay];
}
-(BOOL)isImage
{
  return m_curImage && [m_curImage getImage];
}

-(id)getObjectData
{
  if (m_curImage) return m_curImage;
  UITextField *f = (UITextField*)[self viewWithTag:1002];
  return f ? f.text : nil;
}

-(NSString *)getFieldName
{
  UITextField *f = (UITextField*)[self viewWithTag:1001];
  return f ? f.text : nil;
}

-(void)dealloc
{
  [m_curImage release];
  [super dealloc];
}

@end
