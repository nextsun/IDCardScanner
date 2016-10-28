//
//  CaseTwoViewController.m
//  IDCardScanner
//
//  Created by Lei Sun on 9/1/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import "CaseTwoViewController.h"
#import <PEPhotoCropEditor/PECropViewController.h>
#import <TesseractOCR/TesseractOCR.h>
#import <UIImage-Resize/UIImage+Resize.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CropViewController.h"


@interface CaseTwoViewController ()<G8TesseractDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,MMCropDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDNumberLabel;
@end

@implementation CaseTwoViewController

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
        [self openEditorWithImage:image];
    }];
    CropViewController *crop=[[CropViewController alloc] init];
    crop.cropdelegate=self;
    
    crop.title = @"剪裁";
    crop.adjustedImage=image;
    
    [picker pushViewController:crop animated:YES];

    
}

- (IBAction)openEditorWithImage:(UIImage*)image;
{
    
    
    

    
    CropViewController *crop=[[CropViewController alloc] init];
    crop.cropdelegate=self;
  
     crop.title = @"剪裁";
    crop.adjustedImage=image;
    
    
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:crop];
    
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}





#pragma mark crop delegate
-(void)didFinishCropping:(UIImage *)finalCropImage from:(CropViewController *)cropObj{
    
    
    [cropObj closeWithCompletion:^{
       
    }];
    //    [self uploadData:finalCropImage];
    NSLog(@"Size of Image %lu",(unsigned long)UIImageJPEGRepresentation(finalCropImage, 0.5).length);
    //    NSLog(@"%@ Image",finalCropImage);
    /*OCR Call*/
//    [self OCR:finalCropImage];
    
    if(finalCropImage!=nil){
       
        self.imageView.image = finalCropImage;
    }
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)recognizeImage:(id)sender {
    
    
    if (!self.imageView.image) {
        
        [SVProgressHUD showInfoWithStatus:@"请先选择图片"];
        return;
    }
    
    
    UIImage* image =  [self.imageView.image resizedImageToFitInSize:CGSizeMake(856, 540) scaleIfSmaller:YES];
    
    
    
    NSLog(@"%@",NSStringFromCGSize(image.size));
    
    [self OCR:image];
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
