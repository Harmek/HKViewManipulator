//
//  HKViewManipulator.h
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

#import <UIKit/UIKit.h>
#import "HKRotationConstraint.h"
#import "HKScalingConstraint.h"
#import "HKTranslationConstraint.h"

enum
{
    RECOGNIZER_TAP          = 0,
    RECOGNIZER_DOUBLE_TAP,
    RECOGNIZER_PAN,
    RECOGNIZER_TAP_MAX      = RECOGNIZER_PAN,
    RECOGNIZER_PINCH,
    RECOGNIZER_ROTATE,
    RECOGNIZER_MAX
};

/**
 * Flags that specify the different types of manipulation that a manipulator can support.
 *
 */
typedef NS_OPTIONS(NSUInteger, HKViewManipulatorType)
{
    HKViewManipulatorTypeNone           = 0,
    HKViewManipulatorTypeTap            = 1 << RECOGNIZER_TAP,
    HKViewManipulatorTypeDoubleTap      = 1 << RECOGNIZER_DOUBLE_TAP,
    HKViewManipulatorTypeTranslate      = 1 << RECOGNIZER_PAN,
    HKViewManipulatorTypeScale          = 1 << RECOGNIZER_PINCH,
    HKViewManipulatorTypeRotate         = 1 << RECOGNIZER_ROTATE
};

@class HKViewManipulator;
/**
 * The protocol that delegates of HKViewManipulator must adopt.
 *
 * It allows the delegate to receive callbacks when a view is tapped or double-tapped (which can be useful if you want to implement some kind of selection).
 */
@protocol HKViewManipulatorDelegate <NSObject>

@optional
- (void)viewManipulator:(HKViewManipulator *)viewManipulator
            detectedTap:(UITapGestureRecognizer *)tapRecognizer
          onSurfaceView:(UIView *)surfaceView
          forTargetView:(UIView *)targetView;

@optional
- (void)viewManipulator:(HKViewManipulator *)viewManipulator
      detectedDoubleTap:(UITapGestureRecognizer *)tapRecognizer
          onSurfaceView:(UIView *)surfaceView
          forTargetView:(UIView *)targetView;

@end

/**
 * HKViewManipulator is the core class to manipulate the transforms of UIViews
 *
 * Although a single "surface view" can share multiple View Manipulators, it is not advised to assign multiple manipulators to a single "target view"
 */
@interface HKViewManipulator : NSObject <UIGestureRecognizerDelegate>

/**
 * Initializes a View Manipulator.
 *
 * @param aType A combination of HKViewManipulatorType flags determining what kind of manipulation will be supported.
 * @param aTargetView The UIView whose transform will be manipulated
 * @param aSurfaceView The UIView that will receive the touch events
 * @sa type
 * @sa targetView
 * @sa surfaceView
 * @returns Returns an initialized HKViewManipulator.
 */
- (id)initWithType:(HKViewManipulatorType)aType
     andTargetView:(UIView *)aTargetView
    andSurfaceView:(UIView *)aSurfaceView;

/**
 * The optional delegate implementing the HKViewManipulatorDelegate protocol.
 */
@property (nonatomic, weak) id<HKViewManipulatorDelegate>   delegate;
@property (nonatomic, assign) BOOL                          enabled;
@property (nonatomic, strong) UIView                        *targetView;
@property (nonatomic, strong) UIView                        *surfaceView;

/**
 * The type(s) of supported manipulation.
 *
 * Combination of one or more HKViewManipulatorType flags
 */
@property (nonatomic, assign) HKViewManipulatorType         type;
@property (nonatomic, assign) NSUInteger                    numberOfTouchesForTap;
@property (nonatomic, assign) NSUInteger                    numberOfTouchesForDoubleTap;
@property (nonatomic, assign) NSUInteger                    minimumNumberOfTouchesForPan;
@property (nonatomic, assign) NSUInteger                    maximumNumberOfTouchesForPan;

@property (nonatomic, assign) CGFloat                       scaleFactor;
@property (nonatomic, assign) CGFloat                       rotationFactor;
@property (nonatomic, assign) CGFloat                       translationFactor;

/**
 * The optional rotation constrain.
 */
@property (nonatomic, strong) HKRotationConstraint          *rotationConstraint;

/**
 * The optional scale constrain.
 */
@property (nonatomic, strong) HKScalingConstraint           *scaleConstraint;

/**
 * The optional translation constrain.
 */
@property (nonatomic, strong) HKTranslationConstraint       *translationConstraint;

@end
