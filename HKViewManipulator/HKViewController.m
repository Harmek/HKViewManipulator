//
//  HKViewController.m
//  HKViewManipulator
//
//  Copyright (c) 2012-2013, Panos Baroudjian.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "HKViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HKViewController ()
@end

@implementation HKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    HKViewManipulatorType type =
        HKViewManipulatorTypeDoubleTap
    |   HKViewManipulatorTypeTranslate
    |   HKViewManipulatorTypeScale
    |   HKViewManipulatorTypeRotate;

    self.redViewManipulator = [[HKViewManipulator alloc] initWithType:type
                                                        andTargetView:self.redView
                                                       andSurfaceView:self.view];
    self.blueViewManipulator = [[HKViewManipulator alloc] initWithType:type
                                                         andTargetView:self.blueView
                                                        andSurfaceView:self.view];
    HKRotationConstraint *rotationConstrain = [[HKRotationConstraint alloc] init];
    self.redViewManipulator.rotationConstraint = rotationConstrain;
    rotationConstrain = [[HKRotationConstraint alloc] initWithMinimumAngle:.0f andMaximumAngle:M_PI];
    self.blueViewManipulator.rotationConstraint = rotationConstrain;
    HKScalingConstraint *scaleConstrain = [[HKScalingConstraint alloc] initWithMinimumScale:1.0f andMaximumScale:2.0f];
    self.blueViewManipulator.scaleConstraint = scaleConstrain;
    self.redViewManipulator.delegate = self;
    self.blueViewManipulator.delegate = self;

    HKTranslationConstraint *translationConstrain = [[HKTranslationConstraint alloc] initWithAxis:CGPointMake(-0.5, 0.5)
                                                                                minimumDistance:.0
                                                                             andMaximumDistance:.0];
    self.blueViewManipulator.translationConstraint = translationConstrain;
    translationConstrain = [[HKTranslationConstraint alloc] initWithAxis:CGPointMake(.0, 1.)
                                                        minimumDistance:.0
                                                     andMaximumDistance:300.0];
    self.redViewManipulator.translationConstraint = translationConstrain;
    self.redViewManipulator.enabled = false;
    self.blueViewManipulator.enabled = false;
}

+ (void)makeViewGlow:(UIView *)view
{
    view.layer.shadowColor = [view.backgroundColor CGColor];
    view.layer.shadowRadius = 4.0f;
    view.layer.shadowOpacity = .9;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.masksToBounds = NO;
}

+ (void)undoViewGlow:(UIView *)view
{
    view.layer.shadowColor = [[UIColor colorWithWhite:.0f alpha:.0f] CGColor];
    view.layer.shadowRadius = .0f;
    view.layer.shadowOpacity = .0f;
}
- (void)viewManipulator:(HKViewManipulator *)viewManipulator
      detectedDoubleTap:(UITapGestureRecognizer *)tapRecognizer
          onSurfaceView:(UIView *)surfaceView
          forTargetView:(UIView *)targetView
{
    viewManipulator.enabled = true;
    [HKViewController makeViewGlow:targetView];
    if (viewManipulator == self.redViewManipulator)
    {
        self.blueViewManipulator.enabled = false;
        [HKViewController undoViewGlow:self.blueViewManipulator.targetView];
    }
    else
    {
        self.redViewManipulator.enabled = false;
        [HKViewController undoViewGlow:self.redViewManipulator.targetView];
    }
    [self.view bringSubviewToFront:targetView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
