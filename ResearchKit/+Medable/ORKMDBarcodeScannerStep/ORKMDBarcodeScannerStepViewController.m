//
//  ORKMDBarcodeScannerStepViewController.m
//  Medable Axon
//
//  Copyright (c) 2018 Medable Inc. All rights reserved.
//
//

#import "ORKMDBarcodeScannerStepViewController.h"

#import "ORKMDBarcodeScanner.h"
#import "ORKMDBarcodeScannerStep.h"

#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"

#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"

@interface ORKMDBarcodeScannerStepViewController () <ORKMDBarcodeScannerViewDelegate>

@property (nonatomic, strong) ORKInstructionStepView *instructionStepView;
@property (nonatomic, strong) ORKMDBarcodeScanner *scannerView;

@property (nonatomic, readonly) ORKNavigationContainerView *navigation;

@property (nonatomic, copy) NSString *scannerOutput;

@end

#pragma mark -

@implementation ORKMDBarcodeScannerStepViewController

- (instancetype)initWithStep:(ORKStep *)step
{
    self = [super initWithStep:step];
    
    if (self)
    {
        NSParameterAssert([step isKindOfClass:[ORKMDBarcodeScannerStep class]]);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self stepDidChange];
    
    self.instructionStepView = [[ORKInstructionStepView alloc] initWithFrame:self.view.bounds];
    self.instructionStepView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.instructionStepView];
    
    self.scannerView = [[ORKMDBarcodeScanner alloc] initWithFrame:self.view.bounds];
    self.scannerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.scannerView.delegate = self;
    [self.view addSubview:self.scannerView];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scannerView startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.scannerView stopScanning];
}


#pragma mark -

- (ORKNavigationContainerView*)navigation
{
    return self.instructionStepView.continueSkipContainer;
}

- (ORKStepResult *)result
{
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;

    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    
    ORKTextQuestionResult *result = [[ORKTextQuestionResult alloc] initWithIdentifier:self.step.identifier];
    result.textAnswer = self.scannerOutput;
    result.questionType = ORKQuestionTypeText;
    result.endDate = now;
    result.startDate = stepResult.startDate;
    
    [results addObject:result];
    stepResult.results = [results copy];
    
    return stepResult;
}

- (void)stepDidChange
{
    [super stepDidChange];
    
    if (self.step && self.isViewLoaded)
    {
        self.navigation.continueEnabled = YES;
        self.instructionStepView.continueSkipContainer.hidden = NO;
        self.navigation.continueButtonItem = self.continueButtonItem;
        self.instructionStepView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
    }
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    
    self.navigation.skipButtonItem = skipButtonItem;
    self.navigation.skipEnabled = self.step.isOptional;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem
{
    [super setContinueButtonItem:continueButtonItem];
    
    self.navigation.continueButtonItem = continueButtonItem;
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem
{
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    
    self.instructionStepView.headerView.learnMoreButtonItem = learnMoreButtonItem;
}


#pragma mark - ORKMDBarcodeScannerViewDelegate

- (void)didFinishConfiguration
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         if (self.scannerView.isConfigured)
         {
             self.instructionStepView.headerView.captionLabel.text = @"Scan was Successful";
             self.instructionStepView.headerView.instructionLabel.text = @"you should be proud!";
         }
         else
         {
             self.instructionStepView.headerView.captionLabel.text = @"Unable to Scan";
             
             [self.instructionStepView.headerView.instructionLabel setText:
              @"There was a problem using the camera,\nor this device does not support"
              " scanning. Please try updating this device to use the latest version of iOS."];
         }
     }];
}

- (void)didProduceMetadataOutput:(AVMetadataMachineReadableCodeObjectArray *)output
{
    NSString *result = output.firstObject.stringValue;
    self.scannerOutput = result;
    
    if (result.length)
    {
        [self.scannerView removeFromSuperview];
        self.scannerView = nil; // tear down the scanner
        
        [self notifyDelegateOnResultChange];
        self.navigation.continueEnabled = YES;

        [self goForward];
    }
    
}

@end
