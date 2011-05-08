#import <UIKit/UIKit.h>

#import "RootViewController.h"
#import "EditViewController.h"
@interface EditView : UIView {

  ImageFieldRec *m_curImage;
}

-(id) initWithName:(NSString*)name data:(id)obj;
-(BOOL)isImage;
-(void)setImage:(ImageFieldRec *)image;
-(id)getObjectData;
-(NSString *)getFieldName;
- (void)drawRect:(CGRect)rect;

@end

