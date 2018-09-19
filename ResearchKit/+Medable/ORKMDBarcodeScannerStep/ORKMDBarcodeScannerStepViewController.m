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

#import "ORKHelpers_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

@interface ORKMDBarcodeScannerStepViewController () <ORKMDBarcodeScannerViewDelegate>

@property (nonatomic, strong) ORKStepHeaderView *headerView;
@property (nonatomic, strong) ORKMDBarcodeScannerView *scannerView;
@property (nonatomic, strong) ORKNavigationContainerView *continueSkipContainer;

@property (nonatomic, copy) NSString *scannerOutput;
@property (nonatomic, assign) BOOL configurationDone;

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
    
    const CGFloat scannerViewProportion = 0.6;

    // create ORKStepHeaderView at top
    CGRect headerViewFrame = self.view.bounds;
    headerViewFrame.size.height *= scannerViewProportion;
    [self.view addSubview:self.headerView =
     [[ORKStepHeaderView alloc] initWithFrame:headerViewFrame]];
    self.headerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleBottomMargin);
    
    // add ORKNavigationContainerView and place at the bottom
    [self.view addSubview:
     self.continueSkipContainer = [ORKNavigationContainerView new]];
    self.continueSkipContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    // magic #'s copied from imageCaptureView
    self.continueSkipContainer.topMargin = 5;
    self.continueSkipContainer.bottomMargin = 15;
    
    self.continueSkipContainer.neverHasContinueButton = YES;
    self.continueSkipContainer.optional = self.step.isOptional;
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:
      @"H:|[_continueSkipContainer]|" options:0 metrics:nil views:
      NSDictionaryOfVariableBindings(_continueSkipContainer)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_continueSkipContainer
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:(1.0-scannerViewProportion)
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_continueSkipContainer
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    if (!ORKMDBarcodeScannerView.isSuppported)
    {
        [self enableSkip];
        self.configurationDone = YES;
        
        [self.headerView.instructionLabel setText:
         @"Barcode scanning is supported on iOS 10 and above. "
         "Please update your iOS version on your device."];
        self.headerView.captionLabel.text = @"Scanning Unavailble";
    }
    else
    {
        // if we don't set these text labels of ORKInstructionStepView
        // to _something_ here in viewDidLoad, it isn't smart enough
        // to do the right thing when these values are set later.
        self.headerView.captionLabel.text = @" ";
        self.headerView.instructionLabel.text = @" ";
        
        CGRect scannerFrame = self.view.bounds;
        scannerFrame.size.height *= 0.6;
        [self.view addSubview:self.scannerView =
         [[ORKMDBarcodeScannerView alloc] initWithFrame:scannerFrame]];
        self.scannerView.delegate = self;
        [self.scannerView configure];

        // add overlay imageView
        UIImage* image = [UIImage imageNamed:@"barcode overlay"
                                    inBundle:ORKBundle()
               compatibleWithTraitCollection:nil];
        
        UIImageView *overlayImage = [[UIImageView alloc]
                                     initWithImage:[image imageWithRenderingMode:
                                                    UIImageRenderingModeAlwaysTemplate]];
        
        [self.scannerView addSubview:overlayImage];
        overlayImage.frame = self.scannerView.bounds;
        overlayImage.backgroundColor = UIColor.clearColor;
        overlayImage.tintColor = [UIColor colorWithRed:1.0
                                                 green:204.0/255.0
                                                  blue:0 alpha:1.0];
        overlayImage.contentMode = UIViewContentModeScaleAspectFill;
        overlayImage.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleHeight);
        
        self.scannerView.accessibilityHint = self.barcodeScannerStep.accessibilityInstructions;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.configurationDone)
    {
        if (self.scannerView.isConfigured)
        {
            [self.scannerView startScanning];
        }
        else [self enableSkip]; // back navigation
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.configurationDone &&
        self.scannerView.isConfigured)
    {
        [self.scannerView stopScanning];
    }
}

- (ORKMDBarcodeScannerStep *)barcodeScannerStep
{
    return (ORKMDBarcodeScannerStep *)self.step;
}

#pragma mark -

- (ORKStepResult *)result
{
    ORKStepResult *stepResult = [super result];

    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    
    ORKTextQuestionResult *result = [[ORKTextQuestionResult alloc] initWithIdentifier:self.step.identifier];
    result.textAnswer = self.scannerOutput;
    result.questionType = ORKQuestionTypeText;
    result.endDate = stepResult.endDate;
    result.startDate = stepResult.startDate;
    
    [results addObject:result];
    stepResult.results = [results copy];
    
    return stepResult;
}

- (void)enableSkip
{
    self.continueSkipContainer.optional = YES;
    self.continueSkipContainer.skipEnabled = YES;
    self.continueSkipContainer.skipButton.alpha = 1.0;
    [self.continueSkipContainer updateContinueAndSkipEnabled];
}

- (void)stepDidChange
{
    [super stepDidChange];

    if (self.step && self.isViewLoaded)
    {
        self.continueSkipContainer.hidden = NO;
        self.continueSkipContainer.optional = self.step.isOptional;
        self.continueSkipContainer.skipEnabled = self.step.isOptional;
    }
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    self.continueSkipContainer.skipButtonItem = skipButtonItem;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem
{
    // we don't want the "Next" button to be visible, so ignore
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem
{
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    self.headerView.learnMoreButtonItem = learnMoreButtonItem;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - ORKMDBarcodeScannerViewDelegate

- (void)didFinishConfiguration:(NSError* __nullable)error
{
    __weak typeof(self) me = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^
     {
         typeof(me) this = me;
         this.configurationDone = YES;
         
         if (this.scannerView.isConfigured)
         {
             [this.scannerView startScanning];
             
             this.headerView.captionLabel.text = nil;
             [this.headerView.instructionLabel setText:
              this.step.text ?: @"Position barcode or QR code in the frame"];

             [this.continueSkipContainer addSubview:this.headerView];
             
             NSDictionary* headerAndSkipBtn =
             @{
               @"headerView" : this.headerView,
               @"skipButton" : this.continueSkipContainer.skipButton
               };

             [this.continueSkipContainer addConstraints:
              [NSLayoutConstraint constraintsWithVisualFormat:
               @"V:|[headerView]-[skipButton]|" options:0 metrics:nil
                                                        views:headerAndSkipBtn]];
             
             [this.continueSkipContainer addConstraints:
              [NSLayoutConstraint constraintsWithVisualFormat:
               @"H:|[headerView]|" options:0 metrics:nil views:headerAndSkipBtn]];
             
             this.headerView.translatesAutoresizingMaskIntoConstraints = NO;
         }
         else
         {
             this.scannerView.hidden = YES;
             
             if (!error)
             {
                 [this enableSkip];
                 
                 this.headerView.captionLabel.text = @"";
                 
                 [this.headerView.instructionLabel
                  setText:@"Error has occurred, please retake the task."];
             }
             else
             {
                 NSString* message = @"Camera access was disabled for this"
                 " app, please tap settings to enable the camera for this app";
                 
                 UIAlertController *alert = [UIAlertController 
                                             alertControllerWithTitle:@"Camera Unavailable"
                                             message:message preferredStyle:UIAlertControllerStyleAlert];
                 
                 [alert addAction:
                  [UIAlertAction actionWithTitle:@"Settings"
                                           style:UIAlertActionStyleDefault
                                         handler: ^(UIAlertAction * _Nonnull action)
                   {
                       [me goBackward];
                       [UIApplication.sharedApplication openURL:
                        [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                   }]];

                 [alert addAction:
                  [UIAlertAction actionWithTitle:@"Skip" style:UIAlertActionStyleDefault
                                         handler: ^(UIAlertAction * _Nonnull action) { [me goForward]; }]];
                 
                 [this presentViewController:alert animated:YES completion:nil];
             }
         }
         
         [this.headerView setNeedsLayout];
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
