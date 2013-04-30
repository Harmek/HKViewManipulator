//
//  HKViewManipulator.m
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

#import "HKViewManipulator.h"

@interface HKViewManipulator ()
{
    NSMutableArray  *_recognizers;
    NSUInteger      _nbManipulation;
}

- (UIGestureRecognizer *)createGestureRecognizerForType:(Class)type
                                           withSelector:(SEL)selector;
- (void)onTap:(UITapGestureRecognizer *)recognizer;
- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer;
- (void)onPan:(UIPanGestureRecognizer *)recognizer;
- (void)onPinch:(UIPinchGestureRecognizer *)recognizer;
- (void)onRotation:(UIRotationGestureRecognizer *)recognizer;

@end

@implementation HKViewManipulator
@synthesize type                    = _type;

- (id)initWithType:(HKViewManipulatorType)aType
     andTargetView:(UIView *)aTargetView
    andSurfaceView:(UIView *)aSurfaceView;
{
    self = [super init];
    if (self)
    {
        self.enabled = true;
        self.scaleFactor = 1.f;
        self.rotationFactor = 1.f;
        self.translationFactor = 1.f;
        _recognizers = [NSMutableArray arrayWithObjects:
                        [NSNull null],
                        [NSNull null],
                        [NSNull null],
                        [NSNull null],
                        [NSNull null],
                        nil];
        _nbManipulation = 0;

        self.type = aType;

        self.surfaceView = aSurfaceView;
        self.targetView = aTargetView;
    }

    return self;
}

- (UIGestureRecognizer *)createGestureRecognizerForType:(Class)type
                                           withSelector:(SEL)selector
{
    UIGestureRecognizer *result = [[type alloc] initWithTarget:self
                                                        action:selector];
    result.delegate = self;

    return result;
}

- (void)setType:(HKViewManipulatorType)aType
{
    UIView *targetView = self.targetView;
    UIView *surfaceView = self.surfaceView;
    self.targetView = nil;
    self.surfaceView = nil;

    if (aType & HKViewManipulatorTypeTap)
    {
        _recognizers[RECOGNIZER_TAP] = [self createGestureRecognizerForType:[UITapGestureRecognizer class]
                                                               withSelector:@selector(onTap:)];
    }

    if (aType & HKViewManipulatorTypeDoubleTap)
    {
        _recognizers[RECOGNIZER_DOUBLE_TAP] = [self createGestureRecognizerForType:[UITapGestureRecognizer class]
                                                                      withSelector:@selector(onDoubleTap:)];
        ((UITapGestureRecognizer *)_recognizers[RECOGNIZER_DOUBLE_TAP]).numberOfTapsRequired = 2;
    }

    if (aType & HKViewManipulatorTypeTranslate)
    {
        _recognizers[RECOGNIZER_PAN] = [self createGestureRecognizerForType:[UIPanGestureRecognizer class]
                                                               withSelector:@selector(onPan:)];
    }

    if (aType & HKViewManipulatorTypeScale)
    {
        _recognizers[RECOGNIZER_PINCH] = [self createGestureRecognizerForType:[UIPinchGestureRecognizer class]
                                                                 withSelector:@selector(onPinch:)];
    }

    if (aType & HKViewManipulatorTypeRotate)
    {
        _recognizers[RECOGNIZER_ROTATE] = [self createGestureRecognizerForType:[UIRotationGestureRecognizer class]
                                                                  withSelector:@selector(onRotation:)];
    }

    self.targetView = targetView;
    self.surfaceView = surfaceView;
}

- (void)setSurfaceView:(UIView *)aSurfaceView
{
    if (_surfaceView)
    {
        for (size_t i = RECOGNIZER_PAN; i < RECOGNIZER_MAX; ++i)
        {
            if (_recognizers[i] == [NSNull null])
            {
                continue;
            }

            UIGestureRecognizer *recognizer = _recognizers[i];
            if (recognizer)
            {
                [_surfaceView removeGestureRecognizer:recognizer];
            }
        }
    }
    
    _surfaceView = aSurfaceView;
    for (size_t i = RECOGNIZER_PAN; i < RECOGNIZER_MAX; ++i)
    {
        if (_recognizers[i] == [NSNull null])
        {
            continue;
        }

        UIGestureRecognizer *recognizer = _recognizers[i];
        if (recognizer)
        {
            [_surfaceView addGestureRecognizer:recognizer];
        }
    }
}

- (void)setTargetView:(UIView *)aTargetView
{
    if (_targetView)
    {
        for (size_t i = RECOGNIZER_TAP; i < RECOGNIZER_TAP_MAX; ++i)
        {
            if (_recognizers[i] == [NSNull null])
            {
                continue;
            }

            UIGestureRecognizer *recognizer = _recognizers[i];
            if (recognizer)
            {
                [_targetView removeGestureRecognizer:recognizer];
            }
        }
    }

    _targetView = aTargetView;
    for (size_t i = RECOGNIZER_TAP; i < RECOGNIZER_TAP_MAX; ++i)
    {
        if (_recognizers[i] == [NSNull null])
        {
            continue;
        }

        UIGestureRecognizer *recognizer = _recognizers[i];
        if (recognizer)
        {
            [_targetView addGestureRecognizer:recognizer];
        }
    }
}

- (void)setNumberOfTouchesForTap:(NSUInteger)nbFingersForTap
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)_recognizers[RECOGNIZER_TAP];
    tapRecognizer.numberOfTouchesRequired = nbFingersForTap;
}

- (NSUInteger)numberOfTouchesForTap
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)_recognizers[RECOGNIZER_TAP];

    return tapRecognizer.numberOfTouchesRequired;
}

- (void)setNumberOfTouchesForDoubleTap:(NSUInteger)nbFingersForTap
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)_recognizers[RECOGNIZER_DOUBLE_TAP];
    tapRecognizer.numberOfTouchesRequired = nbFingersForTap;
}

- (NSUInteger)numberOfTouchesForDoubleTap
{
    UITapGestureRecognizer *tapRecognizer = (UITapGestureRecognizer *)_recognizers[RECOGNIZER_DOUBLE_TAP];

    return tapRecognizer.numberOfTouchesRequired;
}

- (void)setMinimumNumberOfTouchesForPan:(NSUInteger)minimumNumberOfTouchesForPan
{
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)_recognizers[RECOGNIZER_PAN];

    panRecognizer.minimumNumberOfTouches = minimumNumberOfTouchesForPan;
}

- (NSUInteger)minimumNumberOfTouchesForPan
{
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)_recognizers[RECOGNIZER_PAN];

    return panRecognizer.minimumNumberOfTouches;
}

- (void)setMaximumNumberOfTouchesForPan:(NSUInteger)maximumNumberOfTouchesForPan
{
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)_recognizers[RECOGNIZER_PAN];

    panRecognizer.maximumNumberOfTouches = maximumNumberOfTouchesForPan;
}

- (NSUInteger)maximumNumberOfTouchesForPan
{
    UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)_recognizers[RECOGNIZER_PAN];

    return panRecognizer.maximumNumberOfTouches;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(viewManipulator:detectedTap:onSurfaceView:forTargetView:)])
    {
        [self.delegate viewManipulator:self
                           detectedTap:recognizer
                         onSurfaceView:self.surfaceView
                         forTargetView:self.targetView];
    }
}

- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(viewManipulator:detectedDoubleTap:onSurfaceView:forTargetView:)])
    {
        [self.delegate viewManipulator:self
                     detectedDoubleTap:recognizer
                         onSurfaceView:self.surfaceView
                         forTargetView:self.targetView];
    }
}

- (void)onPan:(UIPanGestureRecognizer *)recognizer
{
    if (!self.enabled)
    {
        return;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        ++_nbManipulation;
    }

    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        --_nbManipulation;
        if (_nbManipulation == 0)
        {
            [self applyScaleConstrains:nil finished:0 context:nil];
        }
    }
    else
    {
        CGPoint translation = [recognizer translationInView:self.surfaceView];
        CGAffineTransform transform = self.targetView.transform;
        HKTranslationConstraint *constrain = self.translationConstraint;

        translation.x *= self.translationFactor;
        translation.y *= self.translationFactor;
        
        if (constrain)
        {
            transform = [constrain applyAxisConstrainOnTransform:transform andTranslation:translation];
        }

        if (!constrain)
        {
            transform.tx += translation.x;
            transform.ty += translation.y;
        }
        
        self.targetView.transform = transform;
    }

    [recognizer setTranslation:CGPointZero
                        inView:self.surfaceView];
}

- (void)onPinch:(UIPinchGestureRecognizer *)recognizer
{
    if (!self.enabled)
    {
        return;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        ++_nbManipulation;
    }
    
    float scale = recognizer.scale * self.scaleFactor;
    CGAffineTransform transform = self.targetView.transform;
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        --_nbManipulation;
        if (_nbManipulation == 0)
        {
            [self applyScaleConstrains:nil finished:0 context:nil];
        }
    }
    else
    {
        transform = CGAffineTransformScale(transform, scale, scale);
        self.targetView.transform = transform;
    }

    recognizer.scale = 1;
}

- (void)onRotation:(UIRotationGestureRecognizer *)recognizer
{
    if (!self.enabled)
    {
        return;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        ++_nbManipulation;
    }

    CGFloat rotation = recognizer.rotation * self.rotationFactor;
    CGAffineTransform transform = self.targetView.transform;
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        --_nbManipulation;
        if (_nbManipulation == 0)
        {
            [self applyScaleConstrains:nil finished:0 context:nil];
        }
    }
    else
    {
        transform = CGAffineTransformRotate(transform, rotation);
        self.targetView.transform = transform;
    }

    [recognizer setRotation:0];
}

- (void)applyScaleConstrains:(NSString *)animationID
                    finished:(NSNumber *)finished
                     context:(void *)context
{
    CGAffineTransform transform = self.targetView.transform;
    if (self.scaleConstraint)
    {
        transform = [self.scaleConstraint applyConstrainOnTransform:transform
                                                          andScale:0];
    }

    NSTimeInterval time = 1.0 / (!!self.translationConstraint
                                 + !!self.rotationConstraint
                                 + !!self.scaleConstraint);
    [UIView animateWithDuration:time
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(applyRotationConstrains:finished:context:)];
                         self.targetView.transform = transform;
                     }
                     completion:nil];
}

- (void)applyRotationConstrains:(NSString *)animationID
                       finished:(NSNumber *)finished
                        context:(void *)context
{
    CGAffineTransform transform = self.targetView.transform;
    if (self.rotationConstraint)
    {
        transform = [self.rotationConstraint applyConstrainOnTransform:transform
                                                          andRotation:0];
    }

    NSTimeInterval time = 1.0 / (!!self.translationConstraint
                                 + !!self.rotationConstraint
                                 + !!self.scaleConstraint);
    [UIView animateWithDuration:time
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(applyTranslationConstrains:finished:context:)];
                         self.targetView.transform = transform;
                     }
                     completion:nil];
}

- (void)applyTranslationConstrains:(NSString *)animationID
                          finished:(NSNumber *)finished
                           context:(void *)context
{
    CGAffineTransform transform = self.targetView.transform;
    if (self.translationConstraint)
    {
        transform = [self.translationConstraint applyLengthConstrainOnTransform:transform
                                                                andTranslation:CGPointZero];
    }
    
    NSTimeInterval time = 1.0 / (!!self.translationConstraint
                                 + !!self.rotationConstraint
                                 + !!self.scaleConstraint);
    [UIView animateWithDuration:time
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.targetView.transform = transform;
                     }
                     completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
