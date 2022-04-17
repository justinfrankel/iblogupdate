#import "ConfigView.h"


#include "../ui_helper.h"


@implementation ConfigView

-(id) initWithParent:(RootViewController*) par
{
  if ((self = [super init]))
  {
    self.backgroundColor = [UIColor whiteColor];

    CGRect b = [self bounds];
    b.origin.y -= 70.0;
    [self setBounds:b];
    int lh=30;
    int w= 320;//[self frame].size.width;
    
    int xo = 3;
    int ypos = 0;
    mklabel(self,0,  xo,ypos,w-6,lh-3, @"URL:");
    ypos += lh-1;
    mkedit(self, 'u', xo,ypos,w-6,lh, par->m_desturl);
    ypos += lh+3;
    
    mklabel(self,0,  xo, ypos, 100, lh-3, @"User: ");
    mkedit(self, 'l', 106, ypos, w-3-106, lh, par->m_destuser);
    ypos += lh+3;
    
    mklabel(self,0,  xo, ypos, 100, lh-3, @"Pass: ");
    mkedit(self, 'p', 106, ypos, w-3-106, lh, par->m_destpass).secureTextEntry=YES;
    ypos += lh+3;
    
    
    mklabel(self,0, xo,ypos,100,lh-3, @"Max dims:");
    mkedit(self,'x',  w-3-203, ypos, 100,lh, [NSString stringWithFormat:@"%d",(int)par->m_maxx]);
    mkedit(self,'y',  w-3-100, ypos, 100,lh,[NSString stringWithFormat:@"%d",(int)par->m_maxy]);

    ypos += lh+3;
    mklabel(self, 0,xo,ypos,200,lh-3, @"Image Qual (0.1-1.0):");
    mkedit(self, 'q',w-3-100,ypos,100,lh, [NSString stringWithFormat:@"%.2f",par->m_jpgq]);

    ypos += lh+3;
    mklabel(self, 0,xo, ypos,200,lh-3, @"Video QualRed (0-2):");
    mkedit(self, 'v', w-3-100, ypos,100,lh, [NSString stringWithFormat:@"%d",par->m_vidq]);
  }
  return self;
}

-(void) saveConfig:(RootViewController *)par
{
  UITextField *f = (UITextField *)[self viewWithTag:'u'];
  if (f) 
  {
    [par->m_desturl release];
    par->m_desturl = [f.text retain];
  }
  f = (UITextField *)[self viewWithTag:'l'];
  if (f)
  {
    [par->m_destuser release];
    par->m_destuser = [f.text retain];
  }
  f = (UITextField *)[self viewWithTag:'p'];
  if (f)
  {
    [par->m_destpass release];
    par->m_destpass = [f.text retain];
  }


  
  f = (UITextField *)[self viewWithTag:'x'];
  if (f) par->m_maxx = [f.text integerValue];
  f = (UITextField *)[self viewWithTag:'y'];
  if (f) par->m_maxy = [f.text integerValue];
  f = (UITextField *)[self viewWithTag:'q'];
  if (f) par->m_jpgq = [f.text floatValue];
  f = (UITextField *)[self viewWithTag:'v'];
  if (f) par->m_vidq = (int)[f.text integerValue];
}

-(void)dealloc
{
  [super dealloc];
}

@end
