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
    
    self.instructionStepView = [[ORKInstructionStepView alloc] initWithFrame:self.view.bounds];
    self.instructionStepView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.instructionStepView];
    
    if (ORKMDBarcodeScannerView.isSuppported)
    {
        CGRect scannerFrame = self.view.bounds;
        scannerFrame.size.height *= 0.6;
        
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
    else
    {
        [self enableSkip];
        self.configurationDone = YES;
        
        self.instructionStepView.headerView.captionLabel.text = @"Scanning Unavailble";
        
        [self.instructionStepView.headerView.instructionLabel setText:
         @"You are using an older version of iOS which does not support barcode scanning. Please update your device."];
    }
    
    if (self.barcodeScannerStep.templateImage)
    {
        UIImageView *overlayImage = [[UIImageView alloc] initWithImage:
                                     self.barcodeScannerStep.templateImage];
        
        [self.scannerView addSubview:overlayImage];
        overlayImage.frame = self.scannerView.bounds;
        overlayImage.backgroundColor = UIColor.clearColor;
        overlayImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    self.scannerView.accessibilityHint = self.barcodeScannerStep.accessibilityInstructions;
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
    self.instructionStepView.continueSkipContainer.optional = YES;
    self.instructionStepView.continueSkipContainer.skipEnabled = YES;
    [self.instructionStepView.continueSkipContainer updateContinueAndSkipEnabled];
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
    // we don't want the "Next" button to be visible, so ignore
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
             
             // add label to display the instructions
             UILabel *instructions = [[UILabel alloc]
                                      initWithFrame:CGRectZero];
             
             [this.view addSubview:instructions];
             
             [instructions setText: this.step.text ?:
              @"Position barcode or QR code in the frame"];
             
             instructions.numberOfLines = 0; // unlimited
             instructions.textAlignment = NSTextAlignmentCenter;
             instructions.lineBreakMode = NSLineBreakByWordWrapping;
             instructions.translatesAutoresizingMaskIntoConstraints = NO;

             NSDictionary* views = NSDictionaryOfVariableBindings(instructions, _scannerView);
             
             [this.view addConstraints: // vertically below _scannerView
              [NSLayoutConstraint constraintsWithVisualFormat:
               @"V:[_scannerView][instructions]|" options:0 metrics:nil views:views]];
            
             [this.view addConstraints: // horizontally stretched to fill view
              [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[instructions]|"
                                                      options:0 metrics:nil views:views]];
             
             instructions.font = this.instructionStepView.headerView.instructionLabel.font;
         }
         else
         {
             if (!error)
             {
                 [this enableSkip];
                 
                 this.instructionStepView.headerView.captionLabel.text = @"";
                 
                 [this.instructionStepView.headerView.instructionLabel
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
