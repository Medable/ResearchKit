//
//  ORKMDBarcodeScanner.m
//  ResearchKit
//
//  Copyright © 2018 medable, inc. All rights reserved.
//

#import "ORKMDBarcodeScanner.h"


@interface ORKMDBarcodeScanner () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) UIView *highlight;
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end


#pragma mark - Implementation

@implementation ORKMDBarcodeScanner


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
    if (self.supportedCodes.count == 0) return;
    if (@available(iOS 10.0, *)) {} else return;

    // Get the back-facing camera for capturing videos
    NSArray *deviceTypes = @[ AVCaptureDeviceTypeBuiltInWideAngleCamera ];
    
    AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession
                                                               discoverySessionWithDeviceTypes:deviceTypes
                                                               mediaType:AVMediaTypeVideo
                                                               position:AVCaptureDevicePositionBack];
    
    AVCaptureDevice *captureDevice = deviceDiscoverySession.devices.firstObject;
    if (captureDevice)
    {
        // Get an instance of the AVCaptureDeviceInput class using the previous
        // device object and set the input device on the capture session.
        NSError *deviceInputDeviceError = nil;
        AVCaptureDeviceInput *deviceInput =
        [AVCaptureDeviceInput deviceInputWithDevice:captureDevice
                                              error:&deviceInputDeviceError];
        
        if (!deviceInputDeviceError)
        {
            // Capture session
            self.captureSession = [AVCaptureSession new];
            [self.captureSession addInput:deviceInput];
            
            // Initialize a AVCaptureMetadataOutput object and
            // set it as the output device to the capture session.
            AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
            
            // must add to capture session first!!
            [self.captureSession addOutput:output];
            output.metadataObjectTypes = self.supportedCodes;
            
            // Set delegate and use the default dispatch queue to execute the call back
            [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

            // Initialize previewLayer and add it as a sublayer to the view's layer.
            self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.layer.bounds;
            
            [self.layer addSublayer:self.previewLayer];
            
            // configure highlight
            self.highlight = [UIView new];
            [self addSubview:self.highlight];
            [self bringSubviewToFront:self.highlight];
            
            self.highlight.layer.borderWidth = 2;
            self.highlight.layer.borderColor = UIColor.redColor.CGColor;
        }
        else
        {
            // TODO: error handling
            NSString *msg = [NSString stringWithFormat:@"%@ - Couldn't initialize: %@", NSStringFromClass([self class]), deviceInputDeviceError.localizedDescription];
            NSAssert(NO, msg);
        }
    }
}

- (BOOL)isConfigured
{
    return ((self.previewLayer != nil) &&
            (self.captureSession.inputs.count == 1) &&
            (self.captureSession.outputs.count == 1));
}


#pragma mark - Accessors

@synthesize supportedCodes = _supportedCodes;

- (AVMetadataObjectTypeArray *)supportedCodes
{
    return _supportedCodes ?:
    @[  // default to all barcodes
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
}

- (void)setSupportedCodes:(AVMetadataObjectTypeArray *)supportedCodes
{
    _supportedCodes = supportedCodes;
    
    AVCaptureMetadataOutput *output = ((AVCaptureMetadataOutput *)
                                       self.captureSession.outputs.firstObject);
    
    if ([output isKindOfClass:[AVCaptureMetadataOutput class]])
    {
        output.metadataObjectTypes = supportedCodes;
    }
}


#pragma mark - Scanning

// Start video capture.
- (void)startScanning
{
    [self.captureSession startRunning];
}

// Stop video capture.
- (void)stopScanning
{
    [self.captureSession stopRunning];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

typedef NSArray<__kindof AVMetadataObject *> AVMetadataObjectArray;

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(AVMetadataObjectArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
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

