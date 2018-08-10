//
//  ORKMDBarcodeScannerStepViewController.m
//  Medable Axon
//
//  Copyright (c) 2018 Medable Inc. All rights reserved.
//
//

#import "ORKMDBarcodeScannerStepViewController.h"

#import "ORKMDBarcodeScannerStep.h"
#import "ORKMDBarcodeScannerView.h"

#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"

#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

@interface ORKMDBarcodeScannerStepViewController () <ORKMDBarcodeScannerViewDelegate>

@property (nonatomic, strong) ORKInstructionStepView *instructionStepView;
@property (nonatomic, strong) ORKMDBarcodeScannerView *scannerView;

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
    [super viewDidLoad];
    
    [self stepDidChange];
    
    self.instructionStepView = [[ORKInstructionStepView alloc] initWithFrame:self.view.bounds];
    self.instructionStepView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.instructionStepView];
    
    self.scannerView = [[ORKMDBarcodeScannerView alloc] initWithFrame:self.view.bounds];
    self.scannerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.scannerView.delegate = self;
    self.scannerView.hidden = YES;
    [self.view addSubview:self.scannerView];

    // if we don't set these text labels of ORKInstructionStepView
    // to _something_ here in viewDidLoad, it isn't smart enough
    // to do the right thing when these values are set later.
    self.instructionStepView.headerView.captionLabel.text = @" ";
    self.instructionStepView.headerView.instructionLabel.text = @" ";

    if (self.barcodeScannerStep.templateImage)
    {
        UIImageView *overlayImage = [[UIImageView alloc] initWithImage:
                                     self.barcodeScannerStep.templateImage];
        
        [self.scannerView addSubview:overlayImage];
        overlayImage.frame = self.scannerView.bounds;
        overlayImage.backgroundColor = UIColor.clearColor;
        overlayImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    else
    {
        UIView* line = [[UIView alloc] initWithFrame:
                        CGRectMake(0, self.scannerView.bounds.size.height/2,
                                   self.scannerView.bounds.size.width, 2)];
        line.backgroundColor = UIColor.redColor;
        [self.scannerView addSubview:line];
    }
    
    self.scannerView.accessibilityHint = self.barcodeScannerStep.accessibilityInstructions;
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

- (ORKMDBarcodeScannerStep *)barcodeScannerStep
{
    return (ORKMDBarcodeScannerStep *)self.step;
}

#pragma mark -

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
        self.instructionStepView.continueSkipContainer.hidden = NO;
        self.instructionStepView.continueSkipContainer.continueEnabled = YES;
        self.instructionStepView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        self.instructionStepView.continueSkipContainer.continueButtonItem = self.continueButtonItem;
    }
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    
    self.instructionStepView.continueSkipContainer.skipButtonItem = skipButtonItem;
    self.instructionStepView.continueSkipContainer.skipEnabled = self.step.isOptional;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem
{
    [super setContinueButtonItem:continueButtonItem];
    
    self.instructionStepView.continueSkipContainer.continueButtonItem = continueButtonItem;
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem
{
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    
    self.instructionStepView.headerView.learnMoreButtonItem = learnMoreButtonItem;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - ORKMDBarcodeScannerViewDelegate

- (void)didFinishConfiguration
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         if (self.scannerView.isConfigured)
         {
             self.scannerView.hidden = NO;
         }
         else
         {
             self.instructionStepView.continueSkipContainer.optional = YES;
             self.instructionStepView.continueSkipContainer.skipEnabled = YES;
             [self.instructionStepView.continueSkipContainer updateContinueAndSkipEnabled];

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
        [self notifyDelegateOnResultChange];
        [self goForward];
    }
    
}

@end
