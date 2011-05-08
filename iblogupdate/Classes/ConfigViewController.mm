//
//  ConfigViewController.m
//  iblogupdate
//
//  Created by Justin on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigView.h"

@implementation ConfigViewController


#pragma mark -
#pragma mark View lifecycle
-(id) initWithRoot:(RootViewController*)rvc
{
  if ((self = [super init]))
  {
    m_rvc = [rvc retain];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneEditing)] autorelease];
}


-(void)loadView
{
  self.view = [[[ConfigView alloc] initWithParent:m_rvc] autorelease];
}

-(void)doneEditing
{
  [(ConfigView *)self.view saveConfig:m_rvc];
  [m_rvc writeConfig];
  [self.navigationController popViewControllerAnimated:YES];
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
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
  [m_rvc release];
  m_rvc=0;
  [super dealloc];
}


@end

