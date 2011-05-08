//
//  EditViewController.m
//  iblogupdate
//
//  Created by Justin on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "EditView.h"

@implementation EditViewController


#pragma mark -
#pragma mark View lifecycle
-(id) initWithRoot:(RootViewController*)rvc index:(NSUInteger)pos
{
  if ((self = [super init]))
  {
    m_rvc = [rvc retain];
    m_editpos = pos;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneEditing)] autorelease];
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:([(EditView *)self.view isImage] ? @"Clear image" : @"Image...") style:UIBarButtonItemStylePlain target:self action:@selector(chooseImage)] autorelease];
}


-(void)loadView
{
  NSString *nmstr = @"";
  id dstr = @"";
  if (m_rvc)
  {
    nmstr = [m_rvc getFieldName:m_editpos];
    dstr = [m_rvc getFieldData:m_editpos];
  }
  self.view = [[[EditView alloc] initWithName:nmstr data:dstr] autorelease];
}

-(void)doneEditing
{
  if (m_rvc) 
  {
    [m_rvc updateField:m_editpos name:[(EditView *)self.view getFieldName] value:[(EditView *)self.view getObjectData]];
  }
    
  [self.navigationController popViewControllerAnimated:YES];
}
-(void)chooseImage
{  
  if ([(EditView *)self.view isImage])
  {
    [(EditView *)self.view setImage:nil];
    self.navigationItem.rightBarButtonItem.title = @"Image...";
  }
  else 
  {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picker animated:YES];
    [picker release];

  }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
  // deprecated
	[picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
  
  if (img)
  {
    ImageFieldRec *r = [[ImageFieldRec alloc] initWithImage:img];
    [(EditView *)self.view setImage:r];
    [r release];
    self.navigationItem.rightBarButtonItem.title = @"Clear image";
  }
  else 
  {
    [(EditView *)self.view setImage:nil];
    self.navigationItem.rightBarButtonItem.title = @"Image...";
  }
	[picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
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

