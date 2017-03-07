//
//  ORKAutocompleteStep.m
//  Pods
//
//  Created by Guillermo Biset on 2/22/17.
//
//

#import "ORKAutocompleteStep.h"
#import "ORKAnswerFormat.h"
#import "ORKAutocompleteStepViewController.h"

@implementation ORKAutocompleteStep

+ (Class)stepViewControllerClass
{
    return [ORKAutocompleteStepViewController class];
}

- (ORKAnswerFormat *)answerFormat
{
    ORKTextAnswerFormat *answerFormat = [ORKTextAnswerFormat new];
    
    answerFormat.multipleLines = NO;
    answerFormat.secureTextEntry = NO;
    answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
    answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    return answerFormat;
}


@end
