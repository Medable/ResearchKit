//
//  ORKMDBarcodeScannerView.h
//  ResearchKit
//
//  Copyright © 2018 medable, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NSArray<AVMetadataObjectType> AVMetadataObjectTypeArray;
typedef NSArray<AVMetadataMachineReadableCodeObject *> AVMetadataMachineReadableCodeObjectArray;


NS_ASSUME_NONNULL_BEGIN

/**
 * protocol for recieving callbacks when a `ORKMDBarcodeScannerView`
 * has finished its self-configuration process and when a supportedCode
 * is found in the camera view
 */
@protocol ORKMDBarcodeScannerViewDelegate

/**
 * notification that the scannerView has finished self-configuration,
 * use `isConfigured` to determine if that configuration succeeded
 */
- (void)didFinishConfiguration:(NSError* __nullable)error;

/**
 * notification that barcode(s) have been detected
 * @param outputObjects Scanned metadata output objects.
 */
- (void)didProduceMetadataOutput:(AVMetadataMachineReadableCodeObjectArray *)outputObjects;

@end

/**
 * view that displays camera preview and looks for 1D and 2D barcodes
 */
@interface ORKMDBarcodeScannerView : UIView

/**
 * return YES if the device has the required OS support
 */
@property (nonatomic, readonly, class) BOOL isSuppported;

/**
 * returns YES if the scanner was successfully self-configured, otherwise NO
 */
@property (nonatomic, readonly) BOOL isConfigured;

/**
 * the delegate to recieve configuration completion and barcode detection callbacks
 */
@property (nonatomic, weak) id<ORKMDBarcodeScannerViewDelegate> delegate;

/**
 * the codes to look for, by default all supported 1D and 2D code formats
 */
@property (nonatomic, readonly) AVMetadataObjectTypeArray *supportedCodes;

/**
 * configure for usage, delegate sould be set before calling this
 */
- (void)configure;

/**
 * enable looking for codes
 */
- (void)startScanning;

/**
 * disable looking for codes
 */
- (void)stopScanning;

@end

NS_ASSUME_NONNULL_END
