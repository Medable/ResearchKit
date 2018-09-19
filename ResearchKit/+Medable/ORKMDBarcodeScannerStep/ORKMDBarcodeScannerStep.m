//
//  ORKMDBarcodeScannerStep.m
//  Medable Axon
//
//  Copyright (c) 2018 Medable Inc. All rights reserved.
//
//

#import "ORKMDBarcodeScannerStep.h"
#import "ORKMDBarcodeScannerStepViewController.h"


@implementation ORKMDBarcodeScannerStep

+ (Class)stepViewControllerClass
{
    return [ORKMDBarcodeScannerStepViewController class];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    ORKMDBarcodeScannerStep *step = [super copyWithZone:zone];
    step.optional = self.isOptional;
    step.templateImage = self.templateImage;
    step.templateImageInsets = self.templateImageInsets;
    step.accessibilityHint = self.accessibilityHint;
    step.accessibilityInstructions = self.accessibilityInstructions;
    return step;
}

@end
