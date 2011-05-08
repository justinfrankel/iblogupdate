#import <UIKit/UIKit.h>

#import "RootViewController.h"
#import "EditViewController.h"
@interface ConfigView : UIView {

}

-(id) initWithParent:(RootViewController *)par;
-(void) saveConfig:(RootViewController *)par;

@end

