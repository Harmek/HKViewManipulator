//
//  HKTranslationConstrain.m
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

#import "HKTranslationConstraint.h"
#import "MathHelper.h"

static const CGFloat    kMAX_DEVIATION  = .3f;

#define CLAMP(x, lower, upper)  MIN(upper, MAX(x, lower))
#define SIGN(x)                 (x < 0 ? -1 : 1)

@implementation HKTranslationConstraint

- (id)init
{
    return [self initWithAxis:CGPointZero
              minimumDistance:.0
           andMaximumDistance:.0];
}

- (id)initWithAxis:(CGPoint)anAxis
   minimumDistance:(CGFloat)min
andMaximumDistance:(CGFloat)max
{
    self = [super init];
    if (self)
    {
        self.axis = anAxis;
        self.minDist = min;
        self.maxDist = max;
    }

    return self;
}

- (void)setAxis:(CGPoint)anAxis
{
    _axis = [MathHelper normalize:anAxis];
}

- (BOOL)canOrNeedsToBeAligned:(CGPoint)translation
{
    if (self.axis.x != .0 || self.axis.y != .0)
    {
        CGPoint         translationAxis = [MathHelper normalize:translation];
        CGFloat         dotProduct      = [MathHelper dotBetween:translationAxis and:self.axis];
        CGFloat         deviation       = fabs(dotProduct);
        if (deviation < kMAX_DEVIATION)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }

    return NO;
}

- (CGAffineTransform)applyAxisConstrainOnTransform:(CGAffineTransform)transform
                                andTranslation:(CGPoint)translation
{
    translation = CGPointMake(translation.x,
                              translation.y);

    if ([self canOrNeedsToBeAligned:translation])
    {
        CGFloat     magnitude   = [MathHelper getLength:translation];

        translation = CGPointMake(SIGN(translation.x) * magnitude * fabs(self.axis.x),
                                  SIGN(translation.y) * magnitude * fabs(self.axis.y));

        transform.tx += translation.x;
        transform.ty += translation.y;
    }

    return transform;
}

- (CGAffineTransform)applyLengthConstrainOnTransform:(CGAffineTransform)transform
                                      andTranslation:(CGPoint)translation
{
    if ((self.minDist == .0 && self.maxDist == .0)
        || (self.axis.x == .0  && self.axis.y == .0))
    {
        return transform;
    }
    
    translation.x += transform.tx;
    translation.y += transform.ty;
    
    CGFloat angle = atan2(self.axis.y, self.axis.x);
    CGPoint projection = CGPointApplyAffineTransform(translation,
                                                          CGAffineTransformMakeRotation(-angle));

    if (projection.x < self.minDist)
    {
        CGPoint vector = [MathHelper normalize:translation];
        transform.tx = vector.x * self.minDist;
        transform.ty = vector.y * self.minDist;
    }
    else if (projection.x > self.maxDist)
    {
        CGPoint vector = [MathHelper normalize:translation];
        transform.tx = vector.x * self.maxDist;
        transform.ty = vector.y * self.maxDist;
    }

    return transform;
}

+ (HKTranslationConstraint *)closestConstrainForTransform:(CGAffineTransform)transform
                                          andTranslation:(CGPoint)translation
                                            inConstrains:(NSArray *)constrains
{
    HKTranslationConstraint *result = nil;
    CGFloat minDist = FLT_MAX;

    translation = [MathHelper normalize:translation];
    for (HKTranslationConstraint *constrain in constrains)
    {
        CGFloat dist = minDist;

        dist = fabs([MathHelper dotBetween:constrain.axis and:translation]);
        if (dist < minDist)
        {
            minDist = dist;
            result = constrain;
        }
    }
    
    return result;
}
@end
