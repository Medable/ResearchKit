//
//  ORKAnimatedCheckmarkView.h
//  ResearchKit
//
//  Created by J.Rodden on 7/30/18.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import <UIKit/UIKit.h>

// NOTE: this copied straight from inside
// ORKCompletionStepViewController.m,
// renamed from ORKCompletionStepView,
// and made a direct subclass of UIView
// instead of the private ORKActiveStepCustomView

@interface ORKAnimatedCheckmarkView : UIView

@property (nonatomic, readonly) CGFloat tickViewSize;

- (void)setAnimationPoint:(CGFloat)animationPoint animated:(BOOL)animated;

@end
