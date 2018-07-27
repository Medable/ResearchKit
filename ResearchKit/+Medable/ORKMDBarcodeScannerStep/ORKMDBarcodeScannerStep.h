//
//  ORKMDBarcodeScannerStep.h
//  Medable Axon
//
//  Copyright (c) 2018 Medable Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ORKQuestionStep.h>

NS_ASSUME_NONNULL_BEGIN

ORK_CLASS_AVAILABLE
@interface ORKMDBarcodeScannerStep : ORKStep

/**
 An image to be displayed over the camera preview.
 
 The image is stretched to fit the available space while retaining its aspect ratio.
 When choosing a size for this asset, be sure to take into account the variations in device
 form factors.
 */
@property (nonatomic, strong) UIImage *templateImage;

/**
 Insets to be used in positioning and sizing the `templateImage`.
 
 The insets are interpreted as percentages relative to the preview frame size.  The left
 and right insets are relative to the width of the preview frame.  The top and bottom
 insets are relative to the height of the preview frame.
 */
@property (nonatomic) UIEdgeInsets templateImageInsets;

/**
 The accessibility hint for the barcode scanner.
 
 This property can be used to specify accessible instructions for scanning.
 The use of this property can assist when the `templateImage` may not be visible
 to the user.
 
 For example, if you want to scan the user's prescription bottle, you may use a template
 image that displays the outline of a bottle.  You may also want to set this property
 to a string such as @"Hold your prescription bottle with the barcode visible, a few inches from your device."
 */
@property (nonatomic, copy) NSString *accessibilityInstructions;

@end

NS_ASSUME_NONNULL_END
