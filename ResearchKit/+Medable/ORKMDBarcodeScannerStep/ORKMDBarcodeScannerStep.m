//
//  ORKMDBarcodeScannerStep.m
//  Medable Axon
//
//  Copyright (c) 2018 Medable Inc. All rights reserved.
//
//

#import <ResearchKit/ResearchKit.h>

#import "ORKMDBarcodeScannerStep.h"
#import "ORKMDBarcodeScannerStepViewController.h"

@implementation ORKMDBarcodeScannerStep

+ (Class)stepViewControllerClass
{
    return [ORKMDBarcodeScannerStepViewController class];
}

@end
