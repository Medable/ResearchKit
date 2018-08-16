//
//  ORKMDBarcodeScannerView.m
//  ResearchKit
//
//  Copyright © 2018 medable, inc. All rights reserved.
//

#import "ORKMDBarcodeScannerView.h"


@interface ORKMDBarcodeScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) dispatch_queue_t sessionQueue;

@property (nonatomic, strong) AVMetadataObjectTypeArray *supportedCodes;

@property (nonatomic) UIView *highlight;

@end


#pragma mark - Implementation

@implementation ORKMDBarcodeScannerView


#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.supportedCodes = @[  // default to all barcodes
                            AVMetadataObjectTypeAztecCode,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypeDataMatrixCode,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeInterleaved2of5Code,
                            AVMetadataObjectTypeITF14Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeUPCECode
                            ];
    
    if (self.supportedCodes.count == 0) return;
    if (self.class.isSuppported) {} else return;
    
    // Capture session
    self.captureSession = [AVCaptureSession new];
    
    // Initialize previewLayer and add it as a sublayer to the view's layer.
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    self.previewLayer.frame = self.layer.bounds;
    self.previewLayer.needsDisplayOnBoundsChange = YES;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.layer addSublayer:self.previewLayer];
    
    // configure highlight
    self.highlight = [UIView new];
    [self addSubview:self.highlight];
    [self bringSubviewToFront:self.highlight];
    
    self.highlight.layer.borderWidth = 2;
    self.highlight.layer.borderColor = UIColor.redColor.CGColor;
    
    // Capture actions should be performed off the main queue to keep the UI responsive
    self.sessionQueue = dispatch_queue_create("barcode scanning session queue", DISPATCH_QUEUE_SERIAL);
    
    // Setup the capture session
    dispatch_async(self.sessionQueue, ^
    {
        [self queue_SetupCaptureSession];
    });
}

- (AVCaptureDevice *)captureDevice
{
    if (self.class.isSuppported) {} else return nil;
    
    // Get the back-facing camera for capturing videos
    NSArray *deviceTypes = @[ AVCaptureDeviceTypeBuiltInWideAngleCamera ];
    
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession
                                                               discoverySessionWithDeviceTypes:deviceTypes
                                                               mediaType:AVMediaTypeVideo
                                                               position:AVCaptureDevicePositionBack];
    
    return deviceDiscoverySession.devices.firstObject;
}

- (void)queue_SetupCaptureSession
{
    NSAssert(self.captureSession != nil, @"Capture session should be created at this point.");

    [self.captureSession beginConfiguration];
    
    NSError *error = nil;
    AVCaptureDevice *device = [self captureDevice];
    if (device)
    {
        // Get an instance of the AVCaptureDeviceInput class using the previous
        // device object and set the input device on the capture session.
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        
        // Initialize a AVCaptureMetadataOutput object and
        // set it as the output device to the capture session.
        AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
        
        if (!error && [self.captureSession canAddInput:input] && [self.captureSession canAddOutput:output])
        {
            [self.captureSession addInput:input];
            
            [self.captureSession addOutput:output];
            output.metadataObjectTypes = self.supportedCodes;   // must add first before specifiying supported codes
            
            // Set delegate and use the default dispatch queue to execute the call back
            [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        }
        else
        {
            [self.previewLayer removeFromSuperlayer];
            
            self.captureSession = nil;
            self.previewLayer = nil;
            
            // we've cleaned up, inability to configure is reported
            // by the owning VC, so there's nothing more to do here
        }
    }
    else
    {
        [self.previewLayer removeFromSuperlayer];
        
        self.captureSession = nil;
        self.previewLayer = nil;
        
        // we've cleaned up, inability to configure is reported
        // by the owning VC, so there's nothing more to do here
    }
    
    [self.captureSession commitConfiguration];
    [self.delegate didFinishConfiguration:error];
}

- (BOOL)isConfigured
{
    return ((self.previewLayer != nil) &&
            (self.captureSession.inputs.count == 1) &&
            (self.captureSession.outputs.count == 1));
}

+ (BOOL)isSuppported
{
    // I'd prefer to just `return @available(...)`
    // but the compiler gives a warning about that
    if (@available(iOS 10.0, *)) return YES; else return NO;
}

#pragma mark - Scanning

// Start video capture.
- (void)startScanning
{
    dispatch_async(self.sessionQueue, ^
    {
        [self.captureSession startRunning];
    });
}

// Stop video capture.
- (void)stopScanning
{
    dispatch_async(self.sessionQueue, ^
    {
        [self.captureSession stopRunning];
    });
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    self.highlight.frame = CGRectZero;
    
    NSMutableArray<AVMetadataMachineReadableCodeObject*>* outputObjects = [NSMutableArray new];
    
    for (AVMetadataMachineReadableCodeObject *metadataObject in metadataObjects)
    {
        if ([self.supportedCodes containsObject:metadataObject.type])
        {
            [outputObjects addObject:metadataObject];
            
            self.highlight.frame = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject].bounds;
        }
    }
    
    [self.delegate didProduceMetadataOutput:outputObjects];
}

@end

