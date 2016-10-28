//
//  CaseOneViewController.m
//  IDCardScanner
//
//  Created by Lei Sun on 9/1/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import "CaseOneViewController.h"
#import <PEPhotoCropEditor/PECropViewController.h>
#import <TesseractOCR/TesseractOCR.h>
#import <UIImage-Resize/UIImage+Resize.h>
#import <SVProgressHUD/SVProgressHUD.h>
//#import "MyPECropRectView.h"
#import <PEPhotoCropEditor/PECropRectView.h>
#import <Aspects/Aspects.h>
#import "PECropRectView+AddFrame.h"

@interface CaseOneViewController ()<PECropViewControllerDelegate,G8TesseractDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDNumberLabel;
@end



@implementation CaseOneViewController

+(void)initialize
{
    
    //通过AOP注入的方式添加两个框框
    [PECropRectView aspect_hookSelector:@selector(initWithFrame:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, CGRect frame) {
       
        PECropRectView* cropRectView = aspectInfo.instance;
        cropRectView.IDCardNameView = [[UIView alloc] initWithFrame:CGRectZero];
        cropRectView.IDCardNameView.layer.borderWidth = 1;
        cropRectView.IDCardNameView.layer.borderColor = [UIColor redColor].CGColor;
        [cropRectView addSubview:cropRectView.IDCardNameView];
        
        
        cropRectView.IDCardNumberView = [[UIView alloc] initWithFrame:CGRectZero];
        cropRectView.IDCardNumberView.layer.borderWidth = 1;
        cropRectView.IDCardNumberView.layer.borderColor = [UIColor redColor].CGColor;
        [cropRectView addSubview:cropRectView.IDCardNumberView];
        
        
    } error:NULL];
    
    
    [PECropRectView aspect_hookSelector:@selector(layoutSubviews) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        PECropRectView* cropRectView = aspectInfo.instance;
        float scale = cropRectView.bounds.size.width /  856;
        cropRectView.IDCardNameView.frame = CGRectMake(160*scale, 60*scale, 220*scale, 70*scale);
        cropRectView.IDCardNumberView.frame = CGRectMake(276*scale, 420*scale, 520*scale, 80*scale);
    
    } error:NULL];
}


- (IBAction)showImagePicker:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Photo Album", nil), nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [actionSheet showFromBarButtonItem:self.cameraButton animated:YES];
//    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];
//    }

}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    

        [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - UIActionSheetDelegate methods

/*
 Open camera or photo album.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) {
        [self openPhotoAlbum];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {
        [self showCamera];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

/*
 Open PECropViewController automattically when image selected.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    
//    PECropViewController *controller = [[PECropViewController alloc] init];
//    controller.title = @"剪裁";
//    
//    controller.delegate = self;
//    
//    controller.image = self.imageView.image;
//    controller.toolbarHidden= YES;
//    controller.cropAspectRatio =  856.0/540.0;
//    controller.keepingCropAspectRatio = YES;
//    
//    [picker pushViewController:controller animated:YES];
//
}

- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    
    controller.title = @"剪裁";
    controller.delegate = self;
   
    controller.image = self.imageView.image;
    controller.toolbarHidden= YES;
    controller.cropAspectRatio =  856.0/540.0;
    controller.keepingCropAspectRatio = YES;

    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    

    [self presentViewController:navigationController animated:YES completion:nil];
    
 }

#pragma mark - PECropViewControllerDelegate methods
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageView.image = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)recognizeImage:(id)sender {
    
    
    if (!self.imageView.image) {
        
        [SVProgressHUD showInfoWithStatus:@"请先选择图片"];
        return;
    }
    
    
    UIImage* image =  [self.imageView.image resizedImageToFitInSize:CGSizeMake(856, 540) scaleIfSmaller:YES];
    
    
    
    NSLog(@"%@",NSStringFromCGSize(image.size));
    
    [self OCR:image];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"image_sample"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}
 - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
}

/*OCR Method Implementation*/
-(void)OCR:(UIImage *)image{
    // Create RecognitionOperation
    
//    CGRect nameRect = CGRectMake(40*4, 16*4, 35*4, 15*4);
//    
//    CGRect IDNumberRect = CGRectMake(70*4, 108*4, 123*4, 15*4);
    
    
    CGRect nameRect = CGRectMake(160, 60, 220, 70);
    
    CGRect IDNumberRect = CGRectMake(276, 420, 520, 80);
 
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"chi_sim"];
    
    // Configure inner G8Tesseract object as described before
//    operation.tesseract.charWhitelist = @"01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    operation.tesseract.image = [image g8_blackAndWhite];
    
   
//    
//    NSString* filePath =[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"blackAndWhite.jpg"];
//    
//    NSLog(@"%@",filePath);
//    [UIImageJPEGRepresentation(operation.tesseract.image, 1) writeToFile:filePath atomically:YES];
    
    
    operation.tesseract.delegate=self;
    operation.tesseract.rect = nameRect;
    // Setup the recognitionCompleteBlock to receive the Tesseract object
    // after text recognition. It will hold the recognized text.
    
//    __weak typeof(operation) weakOperation = operation;
    
    operation.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
        // Retrieve the recognized text upon completion
        
//        __strong typeof(weakOperation) strongOperation = weakOperation;
//        
//         NSArray *characterBoxes = [strongOperation.tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
//        
//        
//        UIImage* image2 =   [strongOperation.tesseract imageWithBlocks:characterBoxes drawText:YES thresholded:YES];
//        
//         UIImageWriteToSavedPhotosAlbum(image2, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        NSLog(@" OCR TEXT NAME: %@", [recognizedTesseract recognizedText]);
        self.nameLabel.text =[@"姓名:" stringByAppendingString: [recognizedTesseract recognizedText]];
    };
    
    
    
    
    
    // Add operation to queue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    
    
    
    
    G8RecognitionOperation *operation2 = [[G8RecognitionOperation alloc] initWithLanguage:@"chi_sim"];
    
    // Configure inner G8Tesseract object as described before
    operation2.tesseract.charWhitelist = @"1234567890X";
    operation2.tesseract.image = [image g8_blackAndWhite];
    operation2.tesseract.delegate=self;
    operation2.tesseract.rect = IDNumberRect;
    // Setup the recognitionCompleteBlock to receive the Tesseract object
    // after text recognition. It will hold the recognized text.
    operation2.recognitionCompleteBlock = ^(G8Tesseract *recognizedTesseract) {
        // Retrieve the recognized text upon completion
        NSLog(@" OCR TEXT IDNumber:%@", [recognizedTesseract recognizedText]);
        self.IDNumberLabel.text = [@"身份证号:" stringByAppendingString:[recognizedTesseract recognizedText]];
    };

    
    [queue addOperation:operation2];

    
}

#pragma mark OCR delegate
- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    //    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
