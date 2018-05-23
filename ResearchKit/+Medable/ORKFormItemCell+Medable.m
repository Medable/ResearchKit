//
//  ORKFormItemCell+Medable.m
//  Axon
//
//  Created by J.Rodden on 5/18/18.
//  Copyright © 2018 Medable Inc. All rights reserved.
//

#import "ResearchKit.h"
#import "ORKFormItemCell.h"
#import "MDRPasswordStrength.h"

@interface ORKFormItemCell ()
- (void)ork_setAnswer:(id)answer;
@end

#pragma mark -

@implementation ORKFormItemTextFieldBasedCell (Medable)

- (void)ork_setAnswer:(id)answer
{
    [super ork_setAnswer:answer];
    
    @try
    {
        if (![answer isKindOfClass:NSString.class]) return;
        
        // Using KVC (valueForKeyPath:) below could trigger an
        // exception if property is not available. This was done
        // in order to bypass compiler/linker restrictions and
        // avoid adding explicit dependencies to this module (RK)
        
        MDRPasswordStrengthBlock passwordStrengthBlock =
        [self.formItem.answerFormat valueForKey:@"passwordStrengthBlock"];
        
        if (passwordStrengthBlock)
        {
            enum { width = 30 };
            BOOL answerIsEmpty = [answer isEqual:NSNull.null];
            UITextField* textField = [self valueForKey:@"textField"];
            UILabel* indicator = ((UILabel*)textField.leftView ?:
                                  [[UILabel alloc] initWithFrame:
                                   CGRectMake(0, 0, width, width)]);
            
            textField.leftView = indicator;
            textField.leftViewMode = UITextFieldViewModeAlways;
            
            BOOL passwordIsAcceptable;
            MDRPasswordStrength strength;
            passwordStrengthBlock(answer, &passwordIsAcceptable, &strength);
            
            UIColor* __nullable (^scoreColor)(void) =
            ^{
                switch (strength)
                {
                    case MDRPasswordStrengthWeak:   return UIColor.redColor;
                    case MDRPasswordStrengthNormal: return UIColor.yellowColor;
                    case MDRPasswordStrengthStrong: return UIColor.greenColor;
                }
                
                return (UIColor*)nil;
            };
            
            textField.textColor = scoreColor();
            indicator.text = (answerIsEmpty ? nil :
                              passwordIsAcceptable ? @"👍" : @"👎");
        }
    }
    @catch(...) { } // anticipated exception is due to KVC failure, which means
    // this functionality cannot be supported, so gracefully degrade and move on
}

@end
