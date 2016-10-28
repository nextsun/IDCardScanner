//
//  PECropRectView+AddFrame.m
//  IDCardScanner
//
//  Created by Lei Sun on 9/2/16.
//  Copyright © 2016 IBM. All rights reserved.
//

#import "PECropRectView+AddFrame.h"

#import <objc/runtime.h>

static void * IDCardNameViewKey = &IDCardNameViewKey;
static void * IDCardNumberViewKey = &IDCardNumberViewKey;


@implementation PECropRectView (AddFrame)
@dynamic  IDCardNameView;
@dynamic  IDCardNumberView;


- (UIView *)IDCardNameView {
    return objc_getAssociatedObject(self, IDCardNameViewKey);
}

- (void)setIDCardNameView:(UIView *)nameView {
    objc_setAssociatedObject(self, IDCardNameViewKey, nameView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)IDCardNumberView {
    return objc_getAssociatedObject(self, IDCardNumberViewKey);
}

- (void)setIDCardNumberView:(UIView *)numberView {
    objc_setAssociatedObject(self, IDCardNumberViewKey, numberView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
