//
//  ORKAutocompleteStepView.h
//  Pods
//
//  Created by Guillermo Biset on 2/27/17.
//
//

#import "ORKQuestionStepView.h"
#import "ORKSurveyAnswerCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ORKAutocompleteStep;

@interface ORKAutocompleteStepView : ORKQuestionStepView

@property (nonatomic, strong, nullable) ORKAutocompleteStep *autocompleteStep;

@property (nonatomic, weak) id<ORKSurveyAnswerCellDelegate> answerDelegate;

@end

NS_ASSUME_NONNULL_END
