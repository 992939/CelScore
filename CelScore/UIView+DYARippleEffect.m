//
//  UIView+DYARippleEffect.m
//  Pods
//
//  Created by David Yang on 11/02/2016.
//
//

#import "UIView+DYARippleEffect.h"

#import <objc/runtime.h>

static void *kDYARippleColor = @"kDYARippleColor";
static void *kDYARippleTrailColor = @"kDYARippleTrailColor";

@interface UIView ()
@end

@implementation UIView (DYARippleEffect)

- (UIColor *)rippleColor {
    return objc_getAssociatedObject(self, kDYARippleColor);
}

- (void)setRippleColor:(UIColor *)rippleColor {
    objc_setAssociatedObject(self, kDYARippleColor, rippleColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)rippleTrailColor {
    return objc_getAssociatedObject(self, kDYARippleTrailColor);
}

- (void)setRippleTrailColor:(UIColor *)rippleTrailColor {
    objc_setAssociatedObject(self, kDYARippleTrailColor, rippleTrailColor, OBJC_ASSOCIATION_RETAIN);
}

- (void)dya_ripple:(CGPoint)centerPoint {
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = centerPoint;
    circleShape.fillColor = [self rippleTrailColor].CGColor;
    circleShape.opacity = 0;
    circleShape.masksToBounds = false;
    circleShape.strokeColor = [self rippleColor].CGColor;
    circleShape.lineWidth = 5;

    [self.layer addSublayer:circleShape];

    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1)];

    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;

    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[ scaleAnimation, alphaAnimation ];
    animation.duration = 1.6f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

@end
