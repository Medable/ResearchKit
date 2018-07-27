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

@interface ORKMDBarcodeScannerStepViewController() <ORKMDBarcodeScannerViewDelegate>

@property (nonatomic, strong) ORKStepResult *result;
@property (nonatomic, strong) ORKMDBarcodeScanner *scanner;

@property (nonatomic, readonly) ORKInstructionStepView *stepView;
@property (nonatomic, readonly) ORKNavigationContainerView *navigation;

@end

#pragma mark -

@implementation ORKMDBarcodeScannerStepViewController

- (instancetype)initWithStep:(ORKStep *)step
{
    self = [super initWithStep:step];
    
    if (self)
    {
        NSParameterAssert([step isKindOfClass:
                           [ORKMDBarcodeScannerStep class]]);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self stepDidChange];

    [self.view addSubview:self.stepView];
    
    // barcodeScanner must be on top
    [self.view addSubview:self.scanner];

    if (self.scanner.isConfigured)
    {
        self.stepView.headerView.captionLabel.text = @"Scan was Successful";
        self.stepView.headerView.instructionLabel.text = @"you should be proud!";
    }
    else
    {
        self.stepView.headerView.captionLabel.text = @"Unable to Scan";
        
        [self.stepView.headerView.instructionLabel setText:
         @"There was a problem using the camera,\nor this device does not support"
         " scanning. Please try updating this device to use the latest version of iOS."];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scanner startScanning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scanner stopScanning];
}

#pragma mark -

@synthesize result = _result;

- (ORKStepResult*)result
{
    return _result ?: super.result;
}

@synthesize scanner = _scanner;

- (ORKMDBarcodeScanner*)scanner
{
    if (_scanner != nil) return _scanner;
    
    // use "self." so setter is called
    self.scanner = [[ORKMDBarcodeScanner alloc]
                    initWithFrame:self.view.bounds];
    
    _scanner.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
    return _scanner;
}

- (void)setScanner:(ORKMDBarcodeScanner*)scanner
{
    if (_scanner != scanner)
    {
        _scanner.delegate = nil;
        [_scanner removeFromSuperview];
        
        _scanner = scanner;
        _scanner.delegate = self;
    }
}

@synthesize stepView = _stepView;

- (ORKInstructionStepView *)stepView
{
    if (_stepView != nil) return _stepView;
    
    _stepView = [[ORKInstructionStepView alloc]
                 initWithFrame:self.view.bounds];
    
    _stepView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleHeight);

    return _stepView;
}

- (ORKNavigationContainerView*)navigation
{
    return self.stepView.continueSkipContainer;
}

- (void)saveAnswer:(NSString*)answer
{
    _result = super.result;
    
    if (answer)
    {
        ORKTextQuestionResult *result = [[ORKTextQuestionResult alloc]
                                         initWithIdentifier:self.step.identifier];
        result.textAnswer = answer;
        result.questionType = ORKQuestionTypeText;

        result.endDate = _result.endDate;
        result.startDate = _result.startDate;

        _result.results = @[result];
       
        [self notifyDelegateOnResultChange];
        self.navigation.continueEnabled = YES;
    }
}

- (void)stepDidChange
{
    [super stepDidChange];
    
    if (self.step && self.isViewLoaded)
    {
        self.navigation.continueEnabled = YES;
        self.stepView.continueSkipContainer.hidden = NO;
        self.navigation.continueButtonItem = self.continueButtonItem;
        self.stepView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
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
    self.stepView.headerView.learnMoreButtonItem = learnMoreButtonItem;
}

#pragma mark -

- (void)didProduceMetadataOutput:(AVMetadataMachineReadableCodeObjectArray*) output
{
    self.scanner = nil; // tear down the scanner
    [self saveAnswer:output.firstObject.stringValue];
}

@end
