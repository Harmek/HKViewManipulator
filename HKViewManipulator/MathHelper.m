//
//  MathHelper.m
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

#import "MathHelper.h"

@implementation MathHelper

+ (CGFloat)normalizeAngle:(CGFloat)angle
{
    if (angle < .0f)
    {
        angle += HK_TWO_PI;
    }
    if (angle > HK_TWO_PI)
    {
        angle = fmod(angle, HK_TWO_PI);
    }

    return angle;
}

+ (CGFloat)getAngle:(CGAffineTransform)transform
{
    return atan2(transform.b, transform.a);
}

+ (CGFloat)getScaleX:(CGAffineTransform)transform
{
    return sqrt(transform.a * transform.a + transform.c * transform.c);
}

+ (CGFloat)getScaleY:(CGAffineTransform)transform
{
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

+ (CGFloat)getLength:(CGPoint)point
{
    return sqrt(point.x * point.x + point.y * point.y);
}

+ (CGFloat)dotBetween:(CGPoint)a and:(CGPoint)b
{
    return a.x * b.y + a.y * b.x;
}

+ (CGPoint)normalize:(CGPoint)v
{
    CGFloat length = [MathHelper getLength:v];

    return CGPointMake(v.x / length, v.y /  length);
}

+ (CGAffineTransform)recomposeMatrixWithScale:(CGFloat)scale
                                     andAngle:(CGFloat)angle
                               andTranslation:(CGPoint)translation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scale, scale));
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(angle));
    transform.tx = translation.x;
    transform.ty = translation.y;

    return transform;
}

@end
