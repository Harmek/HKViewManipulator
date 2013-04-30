//
//  HKScaleConstrain.m
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

#import "HKScalingConstraint.h"
#import "MathHelper.h"

@implementation HKScalingConstraint

- (id)init
{
    return [self initWithMinimumScale:FLT_EPSILON
                      andMaximumScale:FLT_MAX];
}

- (id)initWithMinimumScale:(CGFloat)aMinScale
           andMaximumScale:(CGFloat)aMaxScale
{
    self = [super init];
    if (self)
    {
        self.minScale = aMinScale;
        self.maxScale = aMaxScale;
    }

    return self;
}

- (BOOL)respectsConstraint:(CGFloat)scale
{
    return scale >= self.minScale && scale < self.maxScale;
}

- (CGAffineTransform)applyConstrainOnTransform:(CGAffineTransform)transform
                                      andScale:(CGFloat)scale
{
    CGFloat factor = [MathHelper getScaleX:transform];
    
    if (![self respectsConstraint:factor])
    {
        CGFloat angle = [MathHelper normalizeAngle:atan2(transform.b, transform.a)];
        CGFloat tx = transform.tx;
        CGFloat ty = transform.ty;

        if (factor > self.maxScale)
        {
            scale = self.maxScale;
        }
        else if (factor < self.minScale)
        {
            scale = self.minScale;
        }

        transform = [MathHelper recomposeMatrixWithScale:scale
                                                andAngle:angle
                                          andTranslation:CGPointMake(tx, ty)];
    }

    return transform;
}

+ (HKScalingConstraint *)closestConstrainForTransform:(CGAffineTransform)transform
                                          andScale:(CGFloat)scale
                                      inConstrains:(NSArray *)constrains
{
    HKScalingConstraint *result = nil;
    CGFloat minDist = FLT_MAX;
    CGFloat factor = [MathHelper getScaleX:transform] + scale;

    for (HKScalingConstraint *constrain in constrains)
    {
        CGFloat dist = minDist;

        if ([constrain respectsConstraint:factor])
        {
            continue;
        }

        if (factor > constrain.maxScale)
        {
            dist = fabs(factor - constrain.maxScale);
        }
        else if (factor < constrain.minScale)
        {
            dist = fabs(factor - constrain.minScale);
        }

        if (dist < minDist)
        {
            minDist = dist;
            result = constrain;
        }
    }

    return result;
}

@end
