//
//  CropViewController.h
//  MMCamScanner
//
//  Created by mukesh mandora on 09/06/15.
//  Copyright (c) 2015 madapps. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIImage+fixOrientation.h"
#import "UIImageView+ContentFrame.h"

#import <SVProgressHUD/SVProgressHUD.h>
@class CropViewController;
@protocol MMCropDelegate <NSObject>

-(void)didFinishCropping:(UIImage *)finalCropImage from:(CropViewController *)cropObj;

@end
@interface CropViewController : UIViewController{
    CGFloat _rotateSlider;
    CGRect _initialRect,final_Rect;
}
@property (weak,nonatomic) id<MMCropDelegate> cropdelegate;
@property (strong, nonatomic) UIImageView *sourceImageView;


@property (strong, nonatomic) UIImage *adjustedImage,*cropgrayImage,*cropImage;

//Detect Edges
-(void)detectEdges;
- (void) closeWithCompletion:(void (^)(void))completion ;
@end
