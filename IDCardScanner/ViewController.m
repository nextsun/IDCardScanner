//
//  ViewController.m
//  IDCardScanner
//
//  Created by Lei Sun on 8/30/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Size.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <TesseractOCR/TesseractOCR.h>
#import <TesseractOCR/UIImage+G8FixOrientation.h>
#import <GKImagePicker@robseward/GKImagePicker.h>


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,G8TesseractDelegate>

@property(nonatomic,strong)UIView* photoBgView;
@property(nonatomic,strong)UIImageView* photoView;


@property(nonatomic,strong)UIImage* originalImage;
@property(nonatomic,strong)UIImage* processedImage;

@property(nonatomic,strong)UIView* willScanView;
@property(nonatomic,assign)BOOL processGrayed;

@property (nonatomic, strong) GKImagePicker *imagePicker;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    85.6mm×54.0mm×1.0mm
    float w = 214;
    float h = 135;
    
    
//    UIImage *overlayImage = [UIImage imageNamed:@"overlay214x135"];
//    self.overlayImageView = [self createOverlayImageViewWithImage:overlayImage];
//    self.overlayImageView.image = overlayImage;
//    
    self.photoBgView = [[UIView alloc] initWithFrame:(CGRectMake(0, 64, self.view.width, h))];
    self.photoBgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.photoView = [[UIImageView alloc] initWithFrame:(CGRectMake(0, 0, w, h))];
//    self.photoView.layer.borderColor = [UIColor redColor].CGColor;
//    self.photoView.layer.borderWidth = 1;
    self.photoView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoView.centerX =self.photoBgView.width/2;
    [self.view addSubview:self.photoBgView];
    [self.photoBgView addSubview:self.photoView];
    self.originalImage =[UIImage imageNamed:@"image_sample"];
    self.processedImage = self.originalImage;
    self.photoView.image =   self.processedImage;
    self.processGrayed = NO;
    
    
    
    
    self.willScanView = [[UIView alloc] initWithFrame:(CGRectZero)];
    self.willScanView.layer.borderWidth = 1;
    self.willScanView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.photoView addSubview:self.willScanView];
    
    
    UIColor* btnColor = [UIColor colorWithRed:0.11 green:0.52 blue:0.82 alpha:1];
    
    UIButton* cameraBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cameraBtn.backgroundColor = btnColor;
    [cameraBtn setTitle:@"相机/相册" forState:(UIControlStateNormal)];
    cameraBtn.tag = 1;
    cameraBtn.frame = CGRectMake(50, self.photoBgView.bottom+20, (self.view.width-120)/2, 40);
     [cameraBtn addTarget:self action:@selector(showImagePicker:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton* photoLibBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    photoLibBtn.backgroundColor = btnColor;
     [photoLibBtn setTitle:@"二值化" forState:(UIControlStateNormal)];
    photoLibBtn.tag = 2;
    photoLibBtn.frame = CGRectMake(cameraBtn.right+20, self.photoBgView.bottom+20, (self.view.width-120)/2, 40);
    
    [photoLibBtn addTarget:self action:@selector(makeImageGrayAction) forControlEvents:(UIControlEventTouchUpInside)];
    
     [self.view addSubview:cameraBtn];
     [self.view addSubview:photoLibBtn];
    
    
    
    
//    
//    UIButton* btnCrop = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    btnCrop.backgroundColor = btnColor;
//    [btnCrop setTitle:@"剪裁调整" forState:(UIControlStateNormal)];
//    btnCrop.frame = CGRectMake(cameraBtn.left, photoLibBtn.bottom+20, (self.view.width-120)/2, 40);
//    [btnCrop addTarget:self action:@selector(cropImageAction) forControlEvents:(UIControlEventTouchUpInside)];
//   [self.view addSubview:btnCrop];
//    
//    
//    UIButton* btnGray = [UIButton buttonWithType:(UIButtonTypeCustom)];
//    btnGray.backgroundColor = btnColor;
//    [btnGray setTitle:@"二值化" forState:(UIControlStateNormal)];
//    btnGray.frame = CGRectMake(photoLibBtn.left, cameraBtn.bottom+20, (self.view.width-120)/2, 40);
//    [btnGray addTarget:self action:@selector(makeImageGrayAction) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.view addSubview:btnGray];
//
    
    
    
    UIButton* btnScanName = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanName.backgroundColor = btnColor;
    [btnScanName setTitle:@"姓名" forState:(UIControlStateNormal)];
    btnScanName.frame = CGRectMake(cameraBtn.left, photoLibBtn.bottom+40, (self.view.width-120)/2, 40);
    [btnScanName addTarget:self action:@selector(scanNameAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanName];
    
    
    UIButton* btnScanGender = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanGender.backgroundColor = btnColor;
    [btnScanGender setTitle:@"性别" forState:(UIControlStateNormal)];
    btnScanGender.frame = CGRectMake(photoLibBtn.left, photoLibBtn.bottom+40, (self.view.width-120)/2, 40);
    [btnScanGender addTarget:self action:@selector(scanGenderAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanGender];
    
    
    
    UIButton* btnScanNation = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanNation.backgroundColor = btnColor;
    [btnScanNation setTitle:@"民族" forState:(UIControlStateNormal)];
    btnScanNation.frame = CGRectMake(cameraBtn.left, btnScanName.bottom+20, (self.view.width-120)/2, 40);
    [btnScanNation addTarget:self action:@selector(scanNationAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanNation];
    
    
    UIButton* btnScanBirthday = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanBirthday.backgroundColor = btnColor;
    [btnScanBirthday setTitle:@"出生" forState:(UIControlStateNormal)];
    btnScanBirthday.frame = CGRectMake(photoLibBtn.left, btnScanGender.bottom+20, (self.view.width-120)/2, 40);
    [btnScanBirthday addTarget:self action:@selector(scanBirthdayAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanBirthday];

    
    
    UIButton* btnScanAddress = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanAddress.backgroundColor = btnColor;
    [btnScanAddress setTitle:@"住址" forState:(UIControlStateNormal)];
    btnScanAddress.frame = CGRectMake(cameraBtn.left, btnScanNation.bottom+20, (self.view.width-120)/2, 40);
    [btnScanAddress addTarget:self action:@selector(scanAddressAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanAddress];
    
    
    UIButton* btnScanIDNumber = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanIDNumber.backgroundColor = btnColor;
    [btnScanIDNumber setTitle:@"身份证号" forState:(UIControlStateNormal)];
    btnScanIDNumber.frame = CGRectMake(photoLibBtn.left, btnScanBirthday.bottom+20, (self.view.width-120)/2, 40);
    [btnScanIDNumber addTarget:self action:@selector(scanIDNumberAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanIDNumber];
    
    
    
    UIButton* btnScanFace = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanFace.backgroundColor = btnColor;
    [btnScanFace setTitle:@"人脸识别" forState:(UIControlStateNormal)];
    btnScanFace.frame = CGRectMake(cameraBtn.left, btnScanAddress.bottom+20, (self.view.width-120)/2, 40);
    [btnScanFace addTarget:self action:@selector(scanFaceAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btnScanFace];

    
    
    
    UIButton* btnScanEdge = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btnScanEdge.backgroundColor = btnColor;
    [btnScanEdge setTitle:@"矩形检测" forState:(UIControlStateNormal)];
    btnScanEdge.frame = CGRectMake(photoLibBtn.left, btnScanIDNumber.bottom+20, (self.view.width-120)/2, 40);
    [btnScanEdge addTarget:self action:@selector(scanEdgeAction) forControlEvents:(UIControlEventTouchUpInside)];
//    [self.view addSubview:btnScanEdge];
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)scanEdgeAction
{
    
    UIImage* detectImage = self.processedImage;
    CGImageRef cgimage = detectImage.CGImage;
    
    CIImage* ciimage = [CIImage imageWithCGImage:cgimage];
    NSDictionary* opts =@{CIDetectorAccuracy:CIDetectorAccuracyHigh};
    
    
    
//    detectImage.CGImage
//    CIDetectorImageOrientation
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                              context:nil options:opts];
    NSArray* features = [detector featuresInImage:ciimage];
    
    NSLog(@"%@",features);
    
    
    [self resetPhotoSubViews];
    
    if (!(features.count>0)) {
        
        self.processedImage = detectImage;
        
        self.photoView.image = self.processedImage ;
    }
    
    
    for (CIRectangleFeature *rectFeature in features){
    
        
        
        
        
        
//        :[NSValue valueWithCGPoint:point]
        
        
        CGRect bounds =   rectFeature.bounds;
        
        
        
//        CGImageRef subImageRef = CGImageCreateWithImageInRect(cgimage, bounds);
//    
//              UIGraphicsBeginImageContext(bounds.size);
//        
//        CGContextRef context = UIGraphicsGetCurrentContext();
//      
//        
//        CGContextDrawImage(context, bounds, subImageRef);
//        
//        UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
//        
//        UIGraphicsEndImageContext();
//        
//        
//        self.processedImage = smallImage;
//        
//        self.photoView.image = self.processedImage ;
        
        
        bounds.origin.y = detectImage.size.height - bounds.origin.y-bounds.size.height;
        
        
        
        CGSize imageSize = detectImage.size;
        float scaleX = imageSize.width/self.photoView.frame.size.width;
        float scaleY = imageSize.height/self.photoView.frame.size.height;
        
        
        float scale = MAX(scaleX, scaleY);
        
        
        
        
        CGRect imageRect = CGRectMake((self.photoView.frame.size.width - floor(imageSize.width/scale))/2 , (self.photoView.frame.size.height - floor(imageSize.height/scale))/2, floor(imageSize.width/scale), floor(imageSize.height/scale));
        
        
        
        CGRect showRect = CGRectMake(floor(bounds.origin.x/scale),floor((bounds.origin.y/scale)), floor(bounds.size.width/scale), floor(bounds.size.height/scale));

        //        showRect.origin.y =
        
        UIView* faceView = [[UIView alloc] initWithFrame:showRect];

//        faceView.transform = CGAffineTransformMakeRotation(M_PI_2)
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [self.photoView addSubview:faceView];
        
        
        NSArray* points  = @[[NSValue valueWithCGPoint:rectFeature.topLeft],[NSValue valueWithCGPoint:rectFeature.topRight],[NSValue valueWithCGPoint:rectFeature.bottomLeft],[NSValue valueWithCGPoint:rectFeature.bottomRight]];
        
        [points enumerateObjectsUsingBlock:^(NSValue* obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            
            CGPoint point = [obj CGPointValue];
            
            
            
            
            UIView* leftEyeView = [[UIView alloc] initWithFrame:
                                   CGRectMake(point.x-2,
                                              point.y-2, 4, 4)];
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            
            CGPoint position =  point;
            position.y = self.originalImage.size.height -  position.y;
            
            [leftEyeView setCenter: [self convertToShowPoint:position forImage:detectImage]];
            leftEyeView.layer.cornerRadius = 2;
            [self.photoView  addSubview:leftEyeView];
            
        }];
        
    }
}
-(void)scanFaceAction
{
    
    UIImage* detectImage = self.processedImage;
    CIImage* ciimage = [CIImage imageWithCGImage:detectImage.CGImage];
    NSDictionary* opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:opts];
    NSArray* features = [detector featuresInImage:ciimage];
    
    NSLog(@"%@",features);
    

    [self resetPhotoSubViews];
    
    
    for (CIFaceFeature *faceFeature in features){
        
        
      
        
        
        CGRect bounds =   faceFeature.bounds;
        bounds.origin.y = detectImage.size.height - bounds.origin.y-bounds.size.height;
        
        
        
        CGRect showRect = [self convertToShowRect:bounds forImage:detectImage];
//        showRect.origin.y = 
        
        UIView* faceView = [[UIView alloc] initWithFrame:showRect];
        faceView.transform = CGAffineTransformMakeRotation(faceFeature.faceAngle);
        faceView.tag = 100;
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [self.photoView addSubview:faceView];
        
//        faceFeature.leftEyePosition
        
          CGFloat faceWidth = showRect.size.width;
        if(faceFeature.hasLeftEyePosition) {
            UIView* leftEyeView = [[UIView alloc] initWithFrame:
                                   CGRectMake(faceFeature.leftEyePosition.x-faceWidth*0.15,
                                              faceFeature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            
            CGPoint position =  faceFeature.leftEyePosition;
            position.y = detectImage.size.height -  position.y;
            
            [leftEyeView setCenter: [self convertToShowPoint:position forImage:detectImage]];
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            [self.photoView  addSubview:leftEyeView];
        }
        
        if(faceFeature.hasRightEyePosition) {
            UIView* leftEye = [[UIView alloc] initWithFrame:
                               CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15,
                                          faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            [leftEye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            CGPoint position =  faceFeature.rightEyePosition;
            position.y = detectImage.size.height -  position.y;

            [leftEye setCenter: [self convertToShowPoint:position forImage:detectImage]];
            leftEye.layer.cornerRadius = faceWidth*0.15;
            [self.photoView  addSubview:leftEye];
        }
        
        if(faceFeature.hasMouthPosition) {
            UIView* mouth = [[UIView alloc] initWithFrame:
                             CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2,
                                        faceFeature.mouthPosition.y-faceWidth*0.2, faceWidth*0.4, faceWidth*0.4)];
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            CGPoint position =  faceFeature.mouthPosition;
            position.y = detectImage.size.height -  position.y;

            [mouth setCenter:[self convertToShowPoint:position forImage:detectImage]];
            mouth.layer.cornerRadius = faceWidth*0.2;
            [self.photoView  addSubview:mouth];
        }
        
        
    }
  

}

-(void)scanNameAction
{
    CGRect scanRect = CGRectMake(40, 16, 35, 15);
    
    NSDictionary* result = [self scanAtRect:scanRect];
    
    
    self.willScanView.frame = scanRect;
    
    if (result) {
        
        NSString* resultText = [@"姓名：" stringByAppendingString:result[@"recognizedText"]];
        [SVProgressHUD showInfoWithStatus:resultText];
    }
    
    
}

-(void)scanGenderAction
{
    CGRect scanRect = CGRectMake(40, 31, 15, 15);
    
    NSDictionary* result = [self scanAtRect:scanRect];
    
    
    self.willScanView.frame = scanRect;
    
    if (result) {
        
        NSString* resultText = [@"性别：" stringByAppendingString:result[@"recognizedText"]];
        [SVProgressHUD showInfoWithStatus:resultText];
    }
    
    
}


-(void)scanNationAction
{
    CGRect scanRect = CGRectMake(83, 31, 15, 15);
    
    NSDictionary* result = [self scanAtRect:scanRect];
    
    
    self.willScanView.frame = scanRect;
    
    if (result) {
        
        NSString* resultText = [@"民族：" stringByAppendingString:result[@"recognizedText"]];
        [SVProgressHUD showInfoWithStatus:resultText];
    }
    
    
}


-(void)scanBirthdayAction
{
    CGRect scanRect = CGRectMake(40, 48, 80, 15);
    
    NSDictionary* result = [self scanAtRect:scanRect];
    
    
    self.willScanView.frame = scanRect;
    
    if (result) {
        
        NSString* resultText = [@"出生：" stringByAppendingString:result[@"recognizedText"]];
        [SVProgressHUD showInfoWithStatus:resultText];
    }
    
    
}

-(void)scanAddressAction
{
    CGRect scanRect1 = CGRectMake(40, 68, 92, 11);
    CGRect scanRect2 = CGRectMake(40, 68+11, 92, 11);
    CGRect scanRect3 = CGRectMake(40, 68+11+11, 92, 11);
    
    NSDictionary* result1 = [self scanAtRect:scanRect1];
    
   

    NSMutableString* resultText = [@"住址：" mutableCopy];
    
    if (result1) {
        
         self.willScanView.frame = scanRect1;
        [resultText appendString:result1[@"recognizedText"]];
        
        
         NSDictionary* result2 = [self scanAtRect:scanRect2];
        
        
        if (result2) {
            
            self.willScanView.frame = scanRect2;
            [resultText appendString:result2[@"recognizedText"]];
            NSDictionary* result3 = [self scanAtRect:scanRect3];
            
            
            if (result3) {
                
                self.willScanView.frame = scanRect3;
                [resultText appendString:result3[@"recognizedText"]];
            }
        }
       
        
    }
    
    [SVProgressHUD showInfoWithStatus:resultText];
   
   
    
    
    
    
  
    
    
}
-(void)scanIDNumberAction
{
    CGRect scanRect = CGRectMake(70, 108, 123, 15);
    
    NSDictionary* result = [self scanAtRect:scanRect andCharWhitelist:@"0123456789X"];
    
    
    self.willScanView.frame = scanRect;
    
    if (result) {
        
        NSString* resultText = [@"身份证号：" stringByAppendingString:result[@"recognizedText"]];
        [SVProgressHUD showInfoWithStatus:resultText];
    }
    
    
}







-(NSDictionary*)scanAtRect:(CGRect)scanRect
{
    return [self scanAtRect:scanRect andCharWhitelist:nil];
}


-(CGRect)convertToRealRect:(CGRect)rect forImage:(UIImage*)realImage
{
    CGSize imageSize = realImage.size;
    float scaleX = imageSize.width/self.photoView.frame.size.width;
    float scaleY = imageSize.height/self.photoView.frame.size.height;
    
    
    float scale = MAX(scaleX, scaleY);
    
    
    
    
    CGRect imageRect = CGRectMake((self.photoView.frame.size.width - floor(imageSize.width/scale))/2 , (self.photoView.frame.size.height - floor(imageSize.height/scale))/2, floor(imageSize.width/scale), floor(imageSize.height/scale));
    
    
    
    CGRect realRect = CGRectMake(floor((rect.origin.x- imageRect.origin.x)*scale),floor((rect.origin.y- imageRect.origin.y)*scale), floor(rect.size.width*scale), floor(rect.size.height*scale));
    
    
    
    return realRect;
    
}
-(CGRect)convertToShowRect:(CGRect)realRect forImage:(UIImage*)realImage
{
    CGSize imageSize = realImage.size;
    float scaleX = imageSize.width/self.photoView.frame.size.width;
    float scaleY = imageSize.height/self.photoView.frame.size.height;
    
    
    float scale = MAX(scaleX, scaleY);
    
    
    
    
    CGRect imageRect = CGRectMake((self.photoView.frame.size.width - floor(imageSize.width/scale))/2 , (self.photoView.frame.size.height - floor(imageSize.height/scale))/2, floor(imageSize.width/scale), floor(imageSize.height/scale));
    
    
    
    CGRect showRect = CGRectMake(floor(realRect.origin.x/scale)+imageRect.origin.x,floor((realRect.origin.y/scale)+imageRect.origin.y), floor(realRect.size.width/scale), floor(realRect.size.height/scale));
    
    
    
    return showRect;
    
}
-(CGPoint)convertToShowPoint:(CGPoint)realPoint forImage:(UIImage*)realImage
{
    CGSize imageSize = realImage.size;
    float scaleX = imageSize.width/self.photoView.frame.size.width;
    float scaleY = imageSize.height/self.photoView.frame.size.height;
    
    
    float scale = MAX(scaleX, scaleY);
    
    
    
    
    CGRect imageRect = CGRectMake((self.photoView.frame.size.width - floor(imageSize.width/scale))/2 , (self.photoView.frame.size.height - floor(imageSize.height/scale))/2, floor(imageSize.width/scale), floor(imageSize.height/scale));
    
    
    
    CGPoint showPoint = CGPointMake(floor(realPoint.x/scale)+imageRect.origin.x,floor((realPoint.y/scale)+imageRect.origin.y));
    
    
    
    return showPoint;
    
}

-(NSDictionary*)scanAtRect:(CGRect)scanRect andCharWhitelist:(NSString*)charWhitelist
{
    
    
    
    if (!self.processGrayed) {
        
        [SVProgressHUD showInfoWithStatus:@"请先二值化图片"];
        return  nil;
    }

    
    BOOL isValidateRect =   CGRectContainsRect(self.photoView.bounds, scanRect);
    
    
    
    
    if (!isValidateRect) {
        
        [SVProgressHUD showInfoWithStatus:@"识别区域有误"];
        return  nil;
    }
    
    // Create your G8Tesseract object using the initWithLanguage method:
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"chi_sim"];
    
    // Optionaly: You could specify engine to recognize with.
    // G8OCREngineModeTesseractOnly by default. It provides more features and faster
    // than Cube engine. See G8Constants.h for more information.
    //tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    // Set up the delegate to receive Tesseract's callbacks.
    // self should respond to TesseractDelegate and implement a
    // "- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract"
    // method to receive a callback to decide whether or not to interrupt
    // Tesseract before it finishes a recognition.
    tesseract.delegate = self;
    
    // Optional: Limit the character set Tesseract should try to recognize from
    if (charWhitelist&&charWhitelist.length>0) {
        tesseract.charWhitelist = @"0123456789X";
    }

    
    // This is wrapper for common Tesseract variable kG8ParamTesseditCharWhitelist:
    // [tesseract setVariableValue:@"0123456789" forKey:kG8ParamTesseditCharBlacklist];
    // See G8TesseractParameters.h for a complete list of Tesseract variables
    
    // Optional: Limit the character set Tesseract should not try to recognize from
    //tesseract.charBlacklist = @"OoZzBbSs";
    
    // Specify the image Tesseract should recognize on
    tesseract.image = self.processedImage;
    
    // Optional: Limit the area of the image Tesseract should recognize on to a rectangle
    tesseract.rect = [self convertToRealRect:scanRect forImage:self.processedImage];
    
    // Optional: Limit recognition time with a few seconds
    tesseract.maximumRecognitionTime = 2.0;
    
    // Start the recognition
    [tesseract recognize];
    
    // Retrieve the recognized text
    
    NSString*  recognizedText = [tesseract recognizedText];
    NSLog(@"Result:%@", [tesseract recognizedText]);

    
    if (recognizedText&&recognizedText.length>0) {
        
        NSArray *characterBoxes = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
        
        
        
        NSDictionary* dict = @{@"recognizedText":[tesseract recognizedText],@"characterBoxes":characterBoxes};
        return dict;
    }
    
    return nil;
    
    
    //    //    // You could retrieve more information about recognized text with that methods:
   
    
}


-(void)cropImageAction{
    
  
    [self scanEdgeAction];
   
}

-(void)makeImageGrayAction{
    
    
    self.processedImage = [self.processedImage g8_blackAndWhite];
     self.photoView.image = self.processedImage;
    self.processGrayed = YES;
}

-(void)showImagePicker:(UIButton*)btn
{
    [self showResizablePicker:btn];
}


//#pragma mark - DZImageEditingControllerDelegate
//
//- (void)imageEditingControllerDidCancel:(DZImageEditingController *)editingController
//{
//    [editingController dismissViewControllerAnimated:YES
//                                          completion:nil];
//}
//
//- (void)imageEditingController:(DZImageEditingController *)editingController
//     didFinishEditingWithImage:(UIImage *)editedImage
//{
//    self.originalImage =  editedImage;
//    self.processedImage = self.originalImage;
//    
//    
//    [self resetPhotoSubViews];
//    
//    self.photoView.image = self.processedImage;
//    [editingController dismissViewControllerAnimated:YES
//                                          completion:nil];
//}
//
//#pragma mark - private
//
//
//- (UIImageView *)createOverlayImageViewWithImage:(UIImage *)image
//{
//    CGFloat newX = [UIScreen mainScreen].bounds.size.width / 2 - image.size.width / 2;
//    CGFloat newY = [UIScreen mainScreen].bounds.size.height / 2 - image.size.height / 2;
//    self.frameRect = CGRectMake(newX, newY, image.size.width, image.size.height);
//    return [[UIImageView alloc] initWithFrame:self.frameRect];
//}


-(void)resetPhotoSubViews
{
    
    [[self.photoView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.willScanView.frame = CGRectZero;
    [self.photoView addSubview:self.willScanView];
}
# pragma mark -
# pragma mark GKImagePicker Delegate Methods

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    self.originalImage = image;
    self.processedImage = self.originalImage;
    self.photoView.image = self.originalImage;
     self.processGrayed = NO;
    [self resetPhotoSubViews];
}

//# pragma mark -
//# pragma mark UIImagePickerDelegate Methods
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
//    self.imgView.image = image;
//    
//    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
//        
//        [self.popoverController dismissPopoverAnimated:YES];
//        
//    } else {
//        
//        [picker dismissViewControllerAnimated:YES completion:nil];
//        
//    }
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showResizablePicker:(UIButton*)btn{
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = self.photoView.size;
    self.imagePicker.delegate = self;
    self.imagePicker.resizeableCropArea = YES;
    self.imagePicker.enforceRatioLimits = YES;
    self.imagePicker.maxWidthRatio = 2;
    self.imagePicker.minWidthRatio = 0.5;
   self. imagePicker.useFrontCameraAsDefault = NO;
    
    [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:btn];
}




@end
