//
//  RootViewController.m
//  iblogupdate
//
//  Created by Justin on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "EditViewController.h"
#import "ConfigViewController.h"

#include "../post.h"

WDL_Queue g_upload;
bool g_want_guide_lines=YES;

@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
  [super viewDidLoad];

  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  if (!m_desturl) m_desturl = [def objectForKey:@"desturl"];
  if (!m_desturl) m_desturl = @"http://";

  
  if (!m_destuser) m_destuser = [def objectForKey:@"destuser"];
  if (!m_destuser) m_destuser = @"";
  if (!m_destpass) m_destpass = [def objectForKey:@"destpass"];
  if (!m_destpass) m_destpass = @"";

  
  g_want_guide_lines = [def boolForKey:@"glines"];
  
  m_maxx = [def integerForKey:@"maxx"];
  if (m_maxx < 4) m_maxx=900;
  m_maxy = [def integerForKey:@"maxy"];
  if (m_maxy < 4) m_maxy=600;
  m_jpgq = [def floatForKey:@"jpgq"];
  if (!m_jpgq) m_jpgq = 0.95;
  m_vidq = (int)[def integerForKey:@"vq"];
  
  if (!m_uploaddata || !m_uploadnames || [m_uploaddata count] != [m_uploadnames count])
  {
    [m_uploadnames release];
    [m_uploaddata release];
    m_uploadnames = [[NSMutableArray alloc] init];
    m_uploaddata = [[NSMutableArray alloc] init];
  
    [m_uploadnames addObjectsFromArray:[def objectForKey:@"uploadnames"]];
    [m_uploaddata addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:[def objectForKey:@"uploaddata"]]];
    
    if ([m_uploaddata count] != [m_uploadnames count] || ![m_uploaddata count])
    {    
      [m_uploaddata removeAllObjects];
      [m_uploadnames removeAllObjects];
      [m_uploadnames addObject:@"text"];
      [m_uploaddata addObject:@"example text"];
    
      [m_uploadnames addObject:@"auth"];
      [m_uploaddata addObject:@"authstr"];
    
      UIImage *img = [UIImage imageNamed:@"foo"]; 
    
      if (img)
      {
        [m_uploadnames addObject:@"image"];
        [m_uploaddata addObject:[[[ImageFieldRec alloc] initWithImage:img] autorelease]];
      } 
    }
  }
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(doUpload)] autorelease];
}

-(void)writeConfig
{
  [self.tableView reloadData];

  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  [def setObject:m_desturl forKey:@"desturl"];
  [def setObject:m_destuser forKey:@"destuser"];
  [def setObject:m_destpass forKey:@"destpass"];
  [def setObject:m_uploadnames forKey:@"uploadnames"];
  [def setObject:[NSKeyedArchiver archivedDataWithRootObject:m_uploaddata] forKey:@"uploaddata"];
  
  [def setInteger:m_maxx forKey:@"maxx"];
  [def setInteger:m_maxy forKey:@"maxy"];
  [def setFloat:m_jpgq forKey:@"jpgq"];
  [def setBool:g_want_guide_lines forKey:@"glines"];
  [def setInteger:m_vidq  forKey:@"vq"];
  [def synchronize];
}


-(void) doUpload
{
  int x;
  g_upload.Clear();
  char oink[256];
  oink[0]=0;
  
  for(x=0;x<[m_uploaddata count];x++)
  {
    NSString *nm = [m_uploadnames objectAtIndex:x];
    const char *nmptr = [nm cStringUsingEncoding:NSUTF8StringEncoding];
    if (!nmptr || !*nmptr) continue;

    ImageFieldRec *r = [m_uploaddata objectAtIndex:x];
    if ([r isKindOfClass:[ImageFieldRec class]])
    {
      NSData *d = [r getJPG:m_jpgq maxDim:CGSizeMake(m_maxx,m_maxy)];
      if (d)
      {
        char buf2[1024];
        snprintf(buf2,sizeof(buf2),"%.500s.jpg",nmptr);
        JNL_HTTP_POST_File(&g_upload,nmptr,buf2,[d bytes],(int)[d length]);
      }
    }
    else if ([r isKindOfClass:[NSURL class]])
    {
      NSData *d = [NSData dataWithContentsOfURL:(NSURL *)r];
      if (d)
      {
        char buf2[1024];
        snprintf(buf2,sizeof(buf2),"%.500s.mp4",nmptr);
        JNL_HTTP_POST_File(&g_upload,nmptr,buf2,[d bytes],(int)[d length]);
      }
    }
    else if ([r isKindOfClass:[NSString class]])
    {
      const char *dptr = [(NSString *)r cStringUsingEncoding:NSUTF8StringEncoding];
      
      JNL_HTTP_POST_AddText(&g_upload,nmptr,dptr ? dptr : "");
    }
  }
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload" 
                                                  message:[NSString stringWithFormat:@"Size: %d",g_upload.GetSize()] delegate:self
                                                  cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK",nil];

  [alert show];
  [alert release];
  
  //getJPG
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
  if (buttonIndex==1)
  {
    NSURL *url = [NSURL URLWithString:m_desturl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:g_upload.Get() length:g_upload.GetSize()]];
    [request addValue:@"1.0" forHTTPHeaderField:@"MIME-Version"];
    [request addValue:@"close" forHTTPHeaderField:@"Connection"];
    [request addValue:@"iblogupdate(iphone) (mozilla)" forHTTPHeaderField:@"User-Agent"];
    [request addValue:[NSString stringWithFormat:@"%d",g_upload.GetSize()] forHTTPHeaderField:@"Content-Length"];
    [request addValue:@"multipart/form-data; boundary=" JNL_HTTPPOST_DIV_STRING forHTTPHeaderField:@"Content-type"];

    if ((m_destuser && [m_destuser compare:@""]) ||
        (m_destpass && [m_destpass compare:@""]))
    {
      NSString *authStr = [NSString stringWithFormat:@"%@:%@", m_destuser?m_destuser:@"", m_destpass?m_destpass:@""];
      NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
      NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
      [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    g_upload.Clear();

    NSURLResponse *response = NULL;
    NSError *requestError = NULL;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    NSString *responseString = responseData ? [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] : requestError ? [requestError localizedDescription] : @"unknown error" ;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status" 
                                                    message:responseString delegate:self 
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:responseString];

    [responseString release];
  }
  g_upload.Clear();
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section  
{
  return section==0 ? @"Fields" : @"Destination";
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section==0) return [m_uploadnames count] + 1;
  if (section==1) return 1;
  
  return 0;
}

-(NSString *) getFieldName:(NSUInteger)pos
{
  return [m_uploadnames objectAtIndex:pos];
}
-(id) getFieldData:(NSUInteger)pos
{
  return [m_uploaddata objectAtIndex:pos];
}
-(void) updateField:(NSUInteger)pos name:(NSString *)s value:(id)i
{
  if (s) [m_uploadnames replaceObjectAtIndex:pos withObject:s];
  if (i) [m_uploaddata replaceObjectAtIndex:pos withObject:i];
  [self writeConfig];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  NSString *labelname=nil;
  id labeldata=nil;
  
  static NSString *CellIdentifier = @"Cell";
  int mode=0;
  NSUInteger fp = [indexPath indexAtPosition:0];
  NSUInteger idx = [indexPath indexAtPosition:[indexPath length]-1];
  if (!fp)
  {
    NSUInteger fieldcnt = [m_uploadnames count];
    if (idx<fieldcnt)
    {
      labelname = [m_uploadnames objectAtIndex:idx];
      labeldata = [m_uploaddata objectAtIndex:idx];
    }
    else if (idx == fieldcnt)
    {
      mode=3;
      labelname = @"Add field...";
      CellIdentifier = @"CellAddButton";
    }
  }
  else if (fp == 1 && !idx)
  {
    labelname = @"Destination URL";
    labeldata = [m_desturl retain];
  }

  if (!mode)
  {
    if ([labeldata isKindOfClass:[NSString class]]) 
    {
      mode=1;
      CellIdentifier = @"CellString";
    }
    else if ([labeldata isKindOfClass:[ImageFieldRec class]]) 
    {
      mode=2;
      CellIdentifier = @"CellImage";
    }
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:(mode==2?UITableViewCellStyleDefault:UITableViewCellStyleSubtitle) reuseIdentifier:CellIdentifier] autorelease];
  }
     
  cell.textLabel.text = labelname ? labelname : @"?";
  switch (mode)
  {
    case 1:
      cell.detailTextLabel.text = labeldata;
    break;
    case 2:
      cell.imageView.image = [(ImageFieldRec*)labeldata previewImage];
    break;
  }
    
  return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return [indexPath indexAtPosition:0]==0 && [indexPath indexAtPosition:1] < [m_uploadnames count];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
      if ([indexPath indexAtPosition:0]==0)
      {
        NSUInteger a = [indexPath indexAtPosition:1];
        if (a < [m_uploadnames count])
        {
          [m_uploadnames removeObjectAtIndex:a];
          [m_uploaddata removeObjectAtIndex:a];
          [self writeConfig];
        }
      }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
  if ([indexPath indexAtPosition:0] == 0)
  {
    NSUInteger pos = [indexPath indexAtPosition:1];
    if (pos == [m_uploadnames count])
    {
      [m_uploadnames addObject:@"newfield"];
      [m_uploaddata addObject:@""];
      [tableView reloadData];
    }
    
    EditViewController *vc = [[EditViewController alloc] initWithRoot:self index:pos];
    vc.title = @"Edit field";
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
  }
  else if ([indexPath indexAtPosition:0]==1)
  {
    ConfigViewController *vc = [[ConfigViewController alloc] initWithRoot:self];
    vc.title = @"Configure";
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
  }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
 // printf("tidying up ram\n");
  int x;
  for(x=0;x<[m_uploaddata count]; x++)
  {
    id obj = [m_uploaddata objectAtIndex:x];
    if ([obj isKindOfClass:[ImageFieldRec class]])
    {
      [(ImageFieldRec *)obj freeCaches];
    }
  }
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
  [m_desturl release];
  [m_destuser release];
  [m_destpass release];
  [m_uploadnames release];
  [m_uploaddata release];
  [super dealloc];
}


@end


@implementation ImageFieldRec
-(id)initWithImage:(UIImage *)img
{
  if ((self = [super init]))
  {
    m_img = [img retain];
    m_imgsmallcache = nil;
    zoom = aspect = 1.0f;
    xoffs = yoffs = 0.0f;
  }
  return self;
}
-(void)dealloc
{
  [m_imgsmallcache release];
  [m_img release];
  [super dealloc];
}
-(void)freeImage
{
  [m_img release];
  m_img=0;
  [m_imgsmallcache release];
  m_imgsmallcache=0;
}
-(void)freeCaches
{
  if (m_imgsmallcache)
  {
    //printf("freeing small cache\n");
    [m_imgsmallcache release];
    m_imgsmallcache=0;
  }
}
-(UIImage *)getImage
{
  return m_img;
}
-(UIImage *)previewImage
{
  if (m_img)
  {
    int usew=50,useh=40;
    CGContextRef r=CGBitmapContextCreate(NULL,usew,useh,8,usew*4,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaNoneSkipFirst);
    UIGraphicsPushContext(r);
    [self drawInRect:CGRectMake(0,0,usew,useh) previewMode:0];
    UIGraphicsPopContext();
    CGImageRef img=CGBitmapContextCreateImage(r);
    UIImage *ret = [[UIImage alloc] initWithCGImage:img scale:1.0f orientation:UIImageOrientationDownMirrored];
    CGImageRelease(img);
    CGContextRelease(r);
    
    return [ret autorelease];
  }
  return nil;
}


-(NSData *)getJPG:(float)qual maxDim:(CGSize)dim
{
  if (!m_img) return nil;
  CGSize sz = m_img.size;
  double useratio = aspect * sz.width / sz.height; 
  
  if (dim.width < dim.height * useratio) dim.height = dim.width / useratio;
  else dim.width = dim.height * useratio;
  
  int usew=(int)(dim.width+0.5);
  int useh=(int)(dim.height+0.5);
  
  CGContextRef r=CGBitmapContextCreate(NULL,usew,useh,8,usew*4,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaNoneSkipFirst);
  UIGraphicsPushContext(r);
  
  CGContextSaveGState(r);
  CGContextTranslateCTM(r,0.0,useh);
  CGContextScaleCTM(r,1.0,-1.0);

  [self drawInRect:CGRectMake(0,0,usew,useh) previewMode:-1];
  CGContextRestoreGState(r);
  UIGraphicsPopContext();
  CGImageRef img=CGBitmapContextCreateImage(r);
  UIImage *ret = [[UIImage alloc] initWithCGImage:img];
  CGImageRelease(img);
  CGContextRelease(r);
  
//  UIImageWriteToSavedPhotosAlbum(ret,nil,nil,nil);
 
  return UIImageJPEGRepresentation([ret autorelease],qual);
}

-(void)setImage:(UIImage *)img
{
  [img retain];
  [m_img release];
  m_img=img;
  [m_imgsmallcache release];
  m_imgsmallcache=0;
}


-(void)drawInRect:(CGRect)r
{
  [self drawInRect:r previewMode:1];
}
-(void)drawInRect:(CGRect)r previewMode:(int)pmode
{
  if (m_img)
  {
    CGSize sz = m_img.size;
    double imgratio = sz.width / sz.height;
    
    const int maxsz=480;
    if (pmode>=0 && (sz.height>maxsz || sz.width>maxsz))
    {
      if (!m_imgsmallcache && pmode)
      {
        int usew = imgratio > 1.0 ? maxsz : maxsz*imgratio;
        int useh = imgratio < 1.0 ? maxsz : maxsz/imgratio;
        CGContextRef r=CGBitmapContextCreate(NULL,usew,useh,8,usew*4,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaNoneSkipFirst);
        UIGraphicsPushContext(r);
        [m_img drawInRect:CGRectMake(0,0,usew,useh)];
        UIGraphicsPopContext();
        CGImageRef img=CGBitmapContextCreateImage(r);
        m_imgsmallcache = [[UIImage alloc] initWithCGImage:img scale:1.0f orientation:UIImageOrientationDownMirrored];
        CGImageRelease(img);
        CGContextRelease(r);
      }
    }
    else 
    {
      [m_imgsmallcache release];
      m_imgsmallcache=0;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect destr;
    double useratio = aspect * imgratio; 
    if (useratio > r.size.width / r.size.height)
    {
      destr.size.width = r.size.width;
      destr.size.height = floor(r.size.width / useratio+0.5);
    }
    else
    {
      destr.size.height = r.size.height;
      destr.size.width = floor(r.size.height * useratio+0.5);
    }
    
    destr.origin.x = (r.origin.x + r.size.width*0.5 - destr.size.width*0.5);
    destr.origin.y = (r.origin.y + r.size.height*0.5 - destr.size.height*0.5);
        
    CGContextSaveGState(ctx);
    
    CGRect cr = destr;
    if (pmode>0)
    {
      [[UIColor blackColor] setFill];
      CGRect fr=destr;
      fr.origin.x-=1;
      fr.origin.y-=1;
      fr.size.width+=2; 
      fr.size.height+=2;
      UIRectFrame(fr);
    }
    UIRectClip(destr);
    
    CGSize osz=destr.size;
    double usez=zoom * destr.size.width / sz.width;
    destr.size.width*=zoom;
    destr.size.height*=zoom*aspect;

    destr.origin.x += xoffs*usez + (osz.width - destr.size.width)*0.5;
    destr.origin.y += yoffs*usez + (osz.height - destr.size.height)*0.5;
                    
    if (m_imgsmallcache) [m_imgsmallcache drawInRect:destr];
    else [m_img drawInRect:destr];
    
    if (pmode>0 && g_want_guide_lines) // guide lines. optional?
    {
      CGContextBeginPath(ctx);
      CGFloat comp[4]={0,0,0,1.0};
      CGContextSetStrokeColor(ctx,comp);
      CGContextSetLineWidth(ctx,1);

      CGContextMoveToPoint(ctx,cr.origin.x+cr.size.width*0.333333, cr.origin.y);
      CGContextAddLineToPoint(ctx,cr.origin.x+cr.size.width*0.333333, cr.origin.y+cr.size.height);
      CGContextMoveToPoint(ctx,cr.origin.x+cr.size.width*0.66666, cr.origin.y);
      CGContextAddLineToPoint(ctx,cr.origin.x+cr.size.width*0.66666, cr.origin.y+cr.size.height);

      CGContextMoveToPoint(ctx,cr.origin.x, cr.origin.y + cr.size.height*0.33333);
      CGContextAddLineToPoint(ctx,cr.origin.x+cr.size.width, cr.origin.y + cr.size.height*0.33333);
      CGContextMoveToPoint(ctx,cr.origin.x, cr.origin.y + cr.size.height*0.66666);
      CGContextAddLineToPoint(ctx,cr.origin.x+cr.size.width, cr.origin.y + cr.size.height*0.66666);
      CGContextStrokePath(ctx);
      
    }

    CGContextRestoreGState(ctx);
    
    
  }
}


#pragma mark NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)encoder;
{
//  [encoder encodeObject:UIImagePNGRepresentation(m_img) forKey:@"img"];
}

- (id)initWithCoder:(NSCoder *)decoder;
{
  if ( ![super init] )
    return nil;

  m_img = nil; 
  m_imgsmallcache=nil;
 // NSData *d = [decoder decodeObjectForKey:@"img"];
  //m_img = d  ? [[UIImage imageWithData:d] retain] : nil;
  
  return self;
}

@end
