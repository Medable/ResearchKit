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

@property (nonatomic) BOOL keyboardWasPresentedAtLeastOnce;

@end

@implementation ORKAutocompleteStepViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.view.bounds;
    self.autocompleteStepView = [[ORKAutocompleteStepView alloc] initWithFrame:frame];
    self.autocompleteStepView.answerDelegate = self;
    self.autocompleteStepView.autocompleteStep = [self autocompleteStep];
    
    self.autocompleteStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self setCustomQuestionView:(ORKQuestionStepCustomView *)self.autocompleteStepView];
    
    [self registerForKeyboardNotifications:YES];
}

- (void)dealloc
{
    [self registerForKeyboardNotifications:NO];
}

- (void)registerForKeyboardNotifications:(BOOL)shouldRegister
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (shouldRegister)
    {
        [notificationCenter addObserver:self
                               selector:@selector(keyboardWillShow:)
                                   name:UIKeyboardWillShowNotification object:nil];
    }
    else
    {
        [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ( !self.keyboardWasPresentedAtLeastOnce )
    {
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.autocompleteStepView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:self.autocompleteStepView.frame.size.height];
        [self.autocompleteStepView addConstraint:constraint];
    }
    
    self.keyboardWasPresentedAtLeastOnce = YES;
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
