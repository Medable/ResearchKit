//
//  ORKAnimatedCheckmarkView.m
//  ResearchKit
//
//  Created by me on 7/30/18.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import "ORKAnimatedCheckmarkView.h"

// NOTE: this is merely copied from inside
// ORKCompletionStepViewController.m and
// renamed from ORKCompletionStepView,
// and made a direct subclass of UIView
// instead of the private ORKActiveStepCustomView

@interface ORKAnimatedCheckmarkView()

@property (nonatomic) CGFloat animationPoint;

@end


@implementation ORKAnimatedCheckmarkView
{
    CAShapeLayer *_shapeLayer;
}


- (CGFloat)tickViewSize
{
    return 122;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = self.tickViewSize / 2;
        [self tintColorDidChange];
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:(CGPoint){37, 65}];
        [path addLineToPoint:(CGPoint){50, 78}];
        [path addLineToPoint:(CGPoint){87, 42}];
        path.lineCapStyle = kCGLineCapRound;
        path.lineWidth = 5;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer new];
        shapeLayer.path = path.CGPath;
        shapeLayer.lineWidth = 5;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.frame = self.layer.bounds;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = nil;
        [self.layer addSublayer:shapeLayer];
        _shapeLayer = shapeLayer;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _shapeLayer.frame = self.layer.bounds;
}

- (CGSize)intrinsicContentSize
{
    return (CGSize){self.tickViewSize, self.tickViewSize};
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self intrinsicContentSize];
}

- (void)tintColorDidChange
{
    self.backgroundColor = [self tintColor];
}

- (void)setAnimationPoint:(CGFloat)animationPoint
{
    _shapeLayer.strokeEnd = animationPoint;
    _animationPoint = animationPoint;
}

- (void)setAnimationPoint:(CGFloat)animationPoint animated:(BOOL)animated
{
    CAMediaTimingFunction *timing = [[CAMediaTimingFunction alloc] initWithControlPoints:0.180739998817444 :0 :0.577960014343262 :0.918200016021729];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setTimingFunction:timing];
    [animation setFillMode:kCAFillModeBoth];
    animation.fromValue = @([(CAShapeLayer *)[_shapeLayer presentationLayer] strokeEnd]);
    animation.toValue = @(animationPoint);
    
    animation.duration = 0.3;
    _animationPoint = animationPoint;
    
    _shapeLayer.strokeEnd = animationPoint;
    [_shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return [super accessibilityTraits] | UIAccessibilityTraitImage;
}

@end
