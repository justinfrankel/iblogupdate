//
//  EditViewController.h
//  iblogupdate
//
//  Created by Justin on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"
@interface EditViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate> {

  RootViewController *m_rvc;
  NSUInteger m_editpos;
}

-(id) initWithRoot:(RootViewController*)rvc index:(NSUInteger)pos;

@end
