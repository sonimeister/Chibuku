
#import "PDFViewController.h"
#import "PDFDocument.h"
#import "PDFView.h"
#import "PDFFormContainer.h"
#import "PDFWidgetAnnotationView.h"
#import "PDF.h"

@interface PDFViewController()
    -(void)loadPDFView;
    -(CGRect)currentFrame:(UIInterfaceOrientation)o;
    -(CGPoint)getMargins;
@end

@implementation PDFViewController



-(void)dealloc
{
    [self removeFromParentViewController];
    [_pdfView removeFromSuperview];
    self.pdfView = nil;
    self.document = nil;
    
    [super dealloc];
}


-(id)initWithData:(NSData*)data
{
    self = [super init];
    if(self != nil)
    {
        
        _document = [[PDFDocument alloc] initWithData:data];
    }
    return self;
}

-(id)initWithResource:(NSString*)name
{
    self = [super init];
    if(self!=nil)
    {
        _document = [[PDFDocument alloc] initWithResource:name];
    }
    return self;
}

-(id)initWithPath:(NSString*)path
{
    self = [super init];
    if(self != nil)
    {
        _document = [[PDFDocument alloc] initWithPath:path];
    }
    
    return self;
}

-(CGRect)currentFrame:(UIInterfaceOrientation)o
{
    if(UIInterfaceOrientationIsPortrait(o))
    {
        return CGRectMake(0, 0, PDFDeviceMinorDimension, PDFDeviceMajorDimension);
    }
    else
    {
        return CGRectMake(0, 0, PDFDeviceMajorDimension, PDFDeviceMinorDimension);
    }
    
   
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
   
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    
    self.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = YES;
    [self loadPDFView];
}




-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _pdfView.alpha = 0;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

    for(PDFForm* form in self.document.forms)
    {
        [form removeObservers];
    }
    
    [_pdfView removeFromSuperview];self.pdfView = nil;
    [self loadPDFView];
    
}

-(void)reload
{
    [_document refresh];
    [_pdfView removeFromSuperview];
    [_pdfView release];
    [self loadPDFView];
}

-(void)setBackColor:(UIColor*)color
{
    _pdfView.pdfView.backgroundColor = color;
}

#pragma mark - Hidden

-(void)loadPDFView
{
    id pass = (_document.documentPath?_document.documentPath:_document.documentData);
    
   CGRect frm = [self currentFrame:self.interfaceOrientation];
    
    
    self.view.frame = CGRectMake(0,self.view.frame.origin.y,frm.size.width,frm.size.height-self.view.frame.origin.y);
    
    CGPoint margins = [self getMargins];
    
    NSArray* additionViews = [_document.forms createWidgetAnnotationViewsForSuperviewWithWidth:frm.size.width Margin:margins.x HMargin:margins.y];
        _pdfView = [[PDFView alloc] initWithFrame:self.view.bounds DataOrPath:pass AdditionViews:additionViews];
    [additionViews release];
    [self.view addSubview:_pdfView];
}



 -(CGPoint)getMargins
{
    if(iPad)
    {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPadWMargin,PDFPortraitPadHMargin);
        else return CGPointMake(PDFLandscapePadWMargin,PDFLandscapePadHMargin);
    }
    else
    {
        if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))return CGPointMake(PDFPortraitPhoneWMargin,PDFPortraitPhoneHMargin);
        else return CGPointMake(PDFLandscapePhoneWMargin,PDFLandscapePhoneHMargin);
    }
}



@end
