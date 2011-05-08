
static UILabel *mklabel(UIView *par, int tag, int x, int y, int w, int h, NSString *lbl)
{
  UILabel *obj = [[UILabel alloc] init];
  if (tag) obj.tag = tag;
  obj.text = lbl;
  [obj setFrame:CGRectMake(x,y,w,h)];
  [par addSubview:obj];
  return [obj autorelease];
}

static UITextField *mkedit(UIView *par, int tag, int x, int y, int w, int h, NSString *val)
{
  UITextField *obj = [[UITextField alloc] init];
  if (tag) obj.tag = tag;
  obj.text = val;
  obj.borderStyle = UITextBorderStyleRoundedRect;
  
  [obj setFrame:CGRectMake(x,y,w,h)];
  [par addSubview:obj];
  return [obj autorelease];
}
