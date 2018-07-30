//
//  ORKMDBarcodeScanner.h
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
 *
 */
@protocol ORKMDBarcodeScannerViewDelegate

/**
 *
 */
- (void)didFinishConfiguration;

/**
 *
 * @param outputObjects Scanned metadata output objects.
 */
- (void)didProduceMetadataOutput:(AVMetadataMachineReadableCodeObjectArray *)outputObjects;

@end

/**
 *
 */
@interface ORKMDBarcodeScanner : UIView

/**
 *
 */
@property (nonatomic, readonly) BOOL isConfigured;

/**
 *
 */
@property (nonatomic, weak) id<ORKMDBarcodeScannerViewDelegate> delegate;

/**
 * 
 */
@property (nonatomic, readonly) AVMetadataObjectTypeArray *supportedCodes;

/**
 *
 */
- (void)startScanning;

/**
 *
 */
- (void)stopScanning;

@end

NS_ASSUME_NONNULL_END
