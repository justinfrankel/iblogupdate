#import <UIKit/UIKit.h>

#import "RootViewController.h"
#import "EditViewController.h"
@interface EditView : UIView {

  ImageFieldRec *m_curImage;
  NSURL *m_curVideo;
}

-(id) initWithName:(NSString*)name data:(id)obj;
-(BOOL)isImage;
-(BOOL)isVideo;
-(void)setImage:(ImageFieldRec *)image video:(NSURL *)url;
-(id)getObjectData;
-(NSString *)getFieldName;
- (void)drawRect:(CGRect)rect;

@end

