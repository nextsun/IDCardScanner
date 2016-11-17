//
//  SecondViewController.m
//  IDCardScanner
//
//  Created by Lei Sun on 8/31/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import "SecondViewController.h"
#import <opencv2/opencv.hpp>

//#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <GKImagePicker@robseward/GKImagePicker.h>
#import <TesseractOCR/UIImage+G8FixOrientation.h>
#import <UIImage-Resize/UIImage+Resize.h>

@interface SecondViewController ()<GKImagePickerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) GKImagePicker *imagePicker;



@property (strong, nonatomic) UIImage* originImage;
@property (strong, nonatomic) NSMutableArray* processedItems;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.originImage = self.imageView.image;
    self.processedItems = [@[self.originImage] mutableCopy];
    self.imageView.animationImages = self.processedItems;
       self.imageView.animationDuration = self.processedItems.count;;//设置动画时间
     self.imageView.animationRepeatCount = 0;//设置动画次数 0 表示无限
    [ self.imageView startAnimating];
    
  }
- (IBAction)showImagePicker:(id)sender {
    

    [self pushedNewBtn];
}
- (void)pushedNewBtn
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view.window];
}
#pragma mark- Actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }
    
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:type]){
        if(buttonIndex==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            type = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = NO;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    self.originImage =  [[image fixOrientation] resizedImageToFitInSize:CGSizeMake(1000, 1000) scaleIfSmaller:YES];
    
    
    
    self.processedItems = [@[self.originImage ] mutableCopy];
    self.imageView.animationImages = self.processedItems;
    self.imageView.animationDuration = self.processedItems.count;
    [self.imageView startAnimating];
   
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (IBAction)FaceDetectClicked:(id)sender {
    [self.processedItems removeAllObjects];
    self.processedItems = [@[self.originImage ] mutableCopy];
    [self opencvFaceDetect];
}
- (IBAction)SquaresDetectClicked:(id)sender {
    [self.processedItems removeAllObjects];
    self.processedItems = [@[self.originImage ] mutableCopy];
     [self opencvSquaresDetect];
}

- (void) opencvFaceDetect  {
    @autoreleasepool {
        NSString* cascadePath = [[NSBundle mainBundle]
                                 pathForResource:@"haarcascade_frontalface_alt"
                                 ofType:@"xml"];
        
        cv::CascadeClassifier faceDetector;
        faceDetector.load([cascadePath UTF8String]);
        
        
        //上传图片
        UIImage *image = self.originImage;
        cv::Mat faceImage;
        UIImageToMat(image, faceImage);
        
        // 转为灰度
        cv::Mat gray;
        cvtColor(faceImage, gray, CV_BGR2GRAY);
        [self.processedItems addObject:MatToUIImage(gray)];
        
        // 检测人脸并储存
        std::vector<cv::Rect>faces;
        faceDetector.detectMultiScale(gray, faces,1.1,2,0|CV_HAAR_SCALE_IMAGE,cv::Size(30,30));
        
        // 在每个人脸上画一个红色四方形
        for(unsigned int i= 0;i < faces.size();i++)
        {
            const cv::Rect& face = faces[i];
            cv::Point tl(face.x,face.y);
            cv::Point br = tl + cv::Point(face.width,face.height);
            
            // 四方形的画法
            cv::Scalar magenta = cv::Scalar(255, 0, 255);
            cv::rectangle(faceImage, tl, br, magenta, 4, 8, 0);
        }
        
        [self.processedItems addObject:MatToUIImage(faceImage)];
    
         self.imageView.animationImages = self.processedItems;
        self.imageView.animationDuration = self.processedItems.count;
         [ self.imageView startAnimating];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//
//#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/imgproc/imgproc.hpp>
//#include <opencv2/imgproc/imgproc_c.h>
//
/* angle: finds a cosine of angle between vectors, from pt0->pt1 and from pt0->pt2
 */

double SecondViewControllerAngle(cv::Point pt1, cv::Point pt2, cv::Point pt0)
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

/* findSquares: returns sequence of squares detected on the image
 */
void findSquares(const cv::Mat& src, std::vector<std::vector<cv::Point> >& squares)
{
    cv::Mat src_gray;
    cv::cvtColor(src, src_gray, cv::COLOR_BGR2GRAY);
    
    // Blur helps to decrease the amount of detected edges
    cv::Mat filtered;
    cv::blur(src_gray, filtered, cv::Size(3, 3));
    cv::imwrite(convertWritePath(@"out_blur.jpg"), filtered);
    
    // Detect edges
    cv::Mat edges;
    int thresh = 80;
    cv::Canny(filtered, edges, thresh, thresh*2, 3);
    cv::imwrite(convertWritePath(@"out_edges.jpg"), edges);
    
    // Dilate helps to connect nearby line segments
    cv::Mat dilated_edges;
    cv::dilate(edges, dilated_edges, cv::Mat(), cv::Point(-1, -1), 2, 1, 1); // default 3x3 kernel
    cv::imwrite(convertWritePath(@"out_dilated.jpg"), dilated_edges);
    
    // Find contours and store them in a list
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(dilated_edges, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
    
    // Test contours and assemble squares out of them
    std::vector<cv::Point> approx;
    for (size_t i = 0; i < contours.size(); i++)
    {
        // approximate contour with accuracy proportional to the contour perimeter
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Note: absolute value of an area is used because
        // area may be positive or negative - in accordance with the
        // contour orientation
        if (approx.size() == 4 && std::fabs(contourArea(cv::Mat(approx))) > 1000 &&
            cv::isContourConvex(cv::Mat(approx)))
        {
            double maxCosine = 0;
            for (int j = 2; j < 5; j++)
            {
                double cosine = std::fabs(SecondViewControllerAngle(approx[j%4], approx[j-2], approx[j-1]));
                maxCosine = MAX(maxCosine, cosine);
            }
            
            if (maxCosine < 0.3)
                squares.push_back(approx);
        }
    }
}

/* findLargestSquare: find the largest square within a set of squares
 */
void findLargestSquare(const std::vector<std::vector<cv::Point> >& squares,
                       std::vector<cv::Point>& biggest_square)
{
    if (!squares.size())
    {
        std::cout << "findLargestSquare !!! No squares detect, nothing to do." << std::endl;
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    for (size_t i = 0; i < squares.size(); i++)
    {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = cv::boundingRect(cv::Mat(squares[i]));
        
        //std::cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
        {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}
- (void) opencvSquaresDetect  {
    @autoreleasepool {
        
        UIImage *image = self.originImage;
        cv::Mat src;
        UIImageToMat(image, src);
        

//            cv::Mat src = cv::imread([self convertReadPath:@"dd.jpg"]);
            if (src.empty())
            {
                std::cout << "!!! Failed to open image" << std::endl;
                return ;
            }
        
            std::vector<std::vector<cv::Point> > squares;
//            findSquares(src, squares);
        
        
        
        
        
        
        
        
        cv::Mat src_gray;
        cv::cvtColor(src, src_gray, cv::COLOR_BGR2GRAY);
        
        // Blur helps to decrease the amount of detected edges
        cv::Mat filtered;
        cv::blur(src_gray, filtered, cv::Size(3, 3));
        cv::imwrite(convertWritePath(@"out_blur.jpg"), filtered);
         [self.processedItems addObject: MatToUIImage(filtered)];
        
        // Detect edges
        cv::Mat edges;
        int thresh = 50;
        cv::Canny(filtered, edges, thresh, thresh*2, 3);
        cv::imwrite(convertWritePath(@"out_edges.jpg"), edges);
         [self.processedItems addObject: MatToUIImage(edges)];
        
        // Dilate helps to connect nearby line segments
        cv::Mat dilated_edges;
        cv::dilate(edges, dilated_edges, cv::Mat(), cv::Point(-1, -1), 2, 1, 1); // default 3x3 kernel
        cv::imwrite(convertWritePath(@"out_dilated.jpg"), dilated_edges);
         [self.processedItems addObject: MatToUIImage(dilated_edges)];
        
        // Find contours and store them in a list
        std::vector<std::vector<cv::Point> > contours;
        cv::findContours(dilated_edges, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
        
        // Test contours and assemble squares out of them
        std::vector<cv::Point> approx;
        for (size_t i = 0; i < contours.size(); i++)
        {
            // approximate contour with accuracy proportional to the contour perimeter
            cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
            
            // Note: absolute value of an area is used because
            // area may be positive or negative - in accordance with the
            // contour orientation
            if (approx.size() == 4 && std::fabs(contourArea(cv::Mat(approx))) > 1000 &&
                cv::isContourConvex(cv::Mat(approx)))
            {
                double maxCosine = 0;
                for (int j = 2; j < 5; j++)
                {
                    double cosine = std::fabs(SecondViewControllerAngle(approx[j%4], approx[j-2], approx[j-1]));
                    maxCosine = MAX(maxCosine, cosine);
                }
                
                if (maxCosine < 0.3)
                    squares.push_back(approx);
            }
        }

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
            // Draw all detected squares
            cv::Mat src_squares = src.clone();
            for (size_t i = 0; i < squares.size(); i++)
            {
                const cv::Point* p = &squares[i][0];
                int n = (int)squares[i].size();
                cv::polylines(src_squares, &p, &n, 1, true, cv::Scalar(0, 255, 0), 2, CV_AA);
            }
            cv::imwrite([self convertWritePath:@"out_squares.jpg"], src_squares);
//            cv::imshow("Squares", src_squares);
        
        [self.processedItems addObject: MatToUIImage(src_squares)];
        
            std::vector<cv::Point> largest_square;
            findLargestSquare(squares, largest_square);
        
            // Draw circles at the corners
            for (size_t i = 0; i < largest_square.size(); i++ )
                cv::circle(src, largest_square[i], 4, cv::Scalar(0, 0, 255), cv::FILLED);
            cv::imwrite([self convertWritePath:@"out_corners.jpg"], src);
            
//            cv::imshow("Corners", src);
//            cv::waitKey(0);

         [self.processedItems addObject: MatToUIImage(src)];
        
        
         self.imageView.animationImages = self.processedItems;
          self.imageView.animationDuration = self.processedItems.count;
         [self.imageView startAnimating];
    }
}


-(const char* )convertReadPath:(NSString*)fileName{
    
    //Creating Path to Documents-Directory
    
   
    
    NSString *filePath = [ [NSBundle mainBundle].bundlePath stringByAppendingPathComponent:fileName];
    const char* cPath = [filePath cStringUsingEncoding:NSMacOSRomanStringEncoding];
   
    return cPath;
}
-(const char* )convertWritePath:(NSString*)fileName{
    
    //Creating Path to Documents-Directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    const char* cPath = [filePath cStringUsingEncoding:NSMacOSRomanStringEncoding];
    
    return cPath;
}
const char* convertWritePath(NSString* fileName){
    
    //Creating Path to Documents-Directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    const char* cPath = [filePath cStringUsingEncoding:NSMacOSRomanStringEncoding];
    
    return cPath;
}
@end
