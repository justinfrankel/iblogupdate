//
//  RootViewController.h
//  iblogupdate
//
//  Created by Justin on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
@public
  NSMutableArray *m_uploadnames, *m_uploaddata;
  NSString *m_desturl, *m_destuser, *m_destpass;
  NSInteger m_maxx, m_maxy;
  int m_vidq; // 1=medium, 2=low
  float m_jpgq;
}

-(NSString *) getFieldName:(NSUInteger)pos;
-(id) getFieldData:(NSUInteger)pos;
-(void) updateField:(NSUInteger)pos name:(NSString *)s value:(id)i;
-(void)writeConfig;

@end


@interface ImageFieldRec : NSObject <NSCoding> {
@public
  
  UIImage *m_img;  
  UIImage *m_imgsmallcache;
  float zoom, aspect,xoffs,yoffs;
}

-(id)initWithImage:(UIImage *)img;
-(void)dealloc;
-(void)freeImage;
-(void)freeCaches;
-(UIImage *)getImage;
-(UIImage *)previewImage;
-(void)setImage:(UIImage *)img;
-(void)drawInRect:(CGRect)r;
-(void)drawInRect:(CGRect)r previewMode:(int)pmode;
-(NSData *)getJPG:(float)qual maxDim:(CGSize)dim;

@end
