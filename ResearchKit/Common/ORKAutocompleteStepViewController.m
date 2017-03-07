//
//  ORKAutocompleteStepViewController.m
//  Pods
//
//  Created by Guillermo Biset on 2/22/17.
//
//

#import "ORKAutocompleteStep.h"
#import "ORKAutocompleteStepViewController.h"
#import "ORKAutocompleteStepView.h"

#import "ORKStepViewController_Internal.h"
#import "ORKQuestionStepViewController_Private.h"

@interface ORKQuestionStepViewController () <ORKSurveyAnswerCellDelegate>
@end

@interface ORKAutocompleteStepViewController () <ORKSurveyAnswerCellDelegate>

@property (nonatomic) ORKAutocompleteStepView *autocompleteStepView;

@end

@implementation ORKAutocompleteStepViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.48);
    self.autocompleteStepView = [[ORKAutocompleteStepView alloc] initWithFrame:frame];
    self.autocompleteStepView.answerDelegate = self;
    self.autocompleteStepView.autocompleteStep = [self autocompleteStep];
    
    self.autocompleteStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self setCustomQuestionView:(ORKQuestionStepCustomView *)self.autocompleteStepView];
}

- (ORKAutocompleteStep *)autocompleteStep
{
    return (ORKAutocompleteStep *)self.step;
}

- (BOOL)continueButtonEnabled
{
    NSString *answer = [self performSelector:@selector(answer)];
    if ( ! [answer isKindOfClass:[NSString class] ] )
    {
        return NO;
    }
    
    if ( self.autocompleteStep.restrictValue )
    {
        for ( NSString *possibleAnswer in self.autocompleteStep.completionTextList )
        {
            if ( [possibleAnswer caseInsensitiveCompare:answer] == NSOrderedSame )
            {
                return YES;
            }
        }
        
        return NO;
    }

    BOOL enabled = ( answer.length > 0 || (self.autocompleteStep.optional && !self.skipButtonItem));
    
    return enabled;
}

@end
