//
//  ConfigViewController.h
//  iblogupdate
//
//  Created by Justin on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"
@interface ConfigViewController : UIViewController <UINavigationControllerDelegate> {

  RootViewController *m_rvc;
}

-(id) initWithRoot:(RootViewController*)rvc;

@end
