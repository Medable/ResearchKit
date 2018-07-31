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
#import "ORKAnimatedCheckmarkView.h"
#import "ORKNavigationContainerView.h"

#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"

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
    
    CGRect scannerFrame = self.view.bounds;
    scannerFrame.origin.y += scannerFrame.size.height * 0.25;
    scannerFrame.size.height -= scannerFrame.size.height * 0.5;
    self.scannerView = [[ORKMDBarcodeScannerView alloc] initWithFrame:scannerFrame];
    self.scannerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.scannerView.delegate = self;
    [self.view addSubview:self.scannerView];

    // if we don't set these text labels of ORKInstructionStepView
    // to _something_ here in viewDidLoad, it isn't smart enough
    // to do the right thing when these values are set later.
    self.instructionStepView.headerView.captionLabel.text = @" ";
    self.instructionStepView.headerView.instructionLabel.text = @" ";
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
        self.instructionStepView.continueSkipContainer.hidden = NO;
        self.instructionStepView.continueSkipContainer.continueEnabled = YES;
        self.instructionStepView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        self.instructionStepView.continueSkipContainer.continueButtonItem = self.continueButtonItem;
    }
}

- (void)showCheckmark
{
    ORKAnimatedCheckmarkView *checkmarkView = [ORKAnimatedCheckmarkView new];
    
    [self.instructionStepView addSubview:checkmarkView];
    checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.instructionStepView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:
      [NSString stringWithFormat:@"V:[checkmarkView(%f)]",
       checkmarkView.tickViewSize] options:0 metrics:nil views:
      NSDictionaryOfVariableBindings(checkmarkView)]];
    
    [self.instructionStepView addConstraints:
     @[
       [NSLayoutConstraint constraintWithItem:checkmarkView
                                    attribute:NSLayoutAttributeCenterX
                                    relatedBy:NSLayoutRelationEqual toItem:self.instructionStepView
                                    attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0],
       
       [NSLayoutConstraint constraintWithItem:checkmarkView
                                    attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                       toItem:self.instructionStepView.headerView.instructionLabel
                                    attribute:NSLayoutAttributeBottom multiplier:1.0 constant:40.0],
       
       [NSLayoutConstraint constraintWithItem:checkmarkView attribute:NSLayoutAttributeWidth
                                    relatedBy:NSLayoutRelationEqual toItem:checkmarkView
                                    attribute:NSLayoutAttributeHeight multiplier:1.0 constant:1.0],
       ]];

    [checkmarkView setAnimationPoint:1 animated:YES];
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
             self.instructionStepView.headerView.captionLabel.text = @"Find a barcode/qrcode to capture";
             self.instructionStepView.headerView.instructionLabel.text = @"do it...do it now!";
         }
         else
         {
             self.instructionStepView.headerView.captionLabel.text = @"Unable to Scan";
             
             [self.instructionStepView.headerView.instructionLabel setText:
              @"There was a problem using the camera,\nor this device does not support"
              " scanning. Please try updating this device to use the latest version of iOS."];
         }
         
         [self.view bringSubviewToFront:self.scannerView];
     }];
}

- (void)didProduceMetadataOutput:(AVMetadataMachineReadableCodeObjectArray *)output
{
    NSString *result = output.firstObject.stringValue;
    self.scannerOutput = result;
    
    if (result.length)
    {
        [self showCheckmark];
        
        [self.scannerView removeFromSuperview];
        self.scannerView = nil; // tear down the scanner
        
        [self notifyDelegateOnResultChange];
        self.instructionStepView.continueSkipContainer.continueEnabled = YES;

        self.instructionStepView.headerView.captionLabel.text = @"Scan was Successful";
        self.instructionStepView.headerView.instructionLabel.text = @"you should be proud!";

        //[self goForward]; // spec isn't clear if we should auto-advance or not, mockup suggests no
    }
    
}

@end
