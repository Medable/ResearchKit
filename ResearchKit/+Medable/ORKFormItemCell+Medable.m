//
//  ORKFormItemCell+Medable.m
//  Axon
//
//  Created by J.Rodden on 5/18/18.
//  Copyright © 2018 Medable Inc. All rights reserved.
//

#import "ResearchKit.h"
#import "ORKFormItemCell.h"
#import "ORKTextFieldView.h"
#import "MDRPasswordStrength.h"

// see ORKFormItemCell.m
@interface ORKFormItemCell ()
- (void)ork_setAnswer:(id)answer;
@end

// see ORKFormItemCell.m
@interface ORKFormItemTextFieldBasedCell()
- (ORKUnitTextField *)textField;
@end

#pragma mark -

@implementation ORKFormItemTextFieldBasedCell (Medable)

- (void)ork_setAnswer:(id)answer
{
    [super ork_setAnswer:answer];
    
    NSObject<MDRPasswordStrength>* answerFormat =
    (NSObject<MDRPasswordStrength>*)self.formItem.answerFormat;
    
    BOOL answerIsEmpty = [answer isEqual:[NSNull null]];

    if (!(answerIsEmpty || [answer isKindOfClass:NSString.class]) ||
        ![answerFormat respondsToSelector:@selector(passwordStrengthBlock)]) return;
    
    MDRPasswordStrengthBlock passwordStrengthBlock = answerFormat.passwordStrengthBlock;
    
    if (passwordStrengthBlock)
    {
        enum { width = 30 };
        UITextField* textField = self.textField;
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
        indicator.text = (answerIsEmpty ? nil : (passwordIsAcceptable ? @"👍" : @"👎"));
    }
}

@end
