//
//  ORKFormItemCell+Medable.m
//  Axon
//
//  Created by me on 5/18/18.
//  Copyright © 2018 Medable Inc. All rights reserved.
//

#import "ResearchKit.h"
#import "ORKFormItemCell.h"

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
        // in code below, use KVC, and performSelector:withObject:
        // in order to bypass compiler/linker restrictions and
        // avoid adding explicit dependencies to this module (RK)
        
        Class DBZxcvbn = NSClassFromString(@"DBZxcvbn");
        NSString* answerFormatKeyPath = @"answerFormat.";

        NSString* isSecureTextEntryKeyPath =
        [answerFormatKeyPath stringByAppendingString:@"isSecureTextEntry"];
        
        NSString* minPasswordStrengthKeyPath =
        [answerFormatKeyPath stringByAppendingString:@"minimumPasswordStrength"];
        
        int minimumPasswordStrength =
        [[self.formItem valueForKeyPath:minPasswordStrengthKeyPath] intValue];
        
        if (DBZxcvbn && minimumPasswordStrength &&
            [[self.formItem valueForKeyPath:isSecureTextEntryKeyPath] boolValue])
        {
            enum { width = 30 };
            BOOL answerIsEmpty = [answer isEqual:NSNull.null];
            UITextField* textField = [self valueForKey:@"textField"];
            UILabel* indicator = ((UILabel*)textField.leftView ?:
                                  [[UILabel alloc] initWithFrame:
                                   CGRectMake(0, 0, width, width)]);
            
            textField.leftView = indicator;
            textField.leftViewMode = UITextFieldViewModeAlways;
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id result = (!answerIsEmpty ?
                         [[DBZxcvbn new] performSelector:
                          NSSelectorFromString(@"passwordStrength:")
                                              withObject:answer] : nil);
            #pragma clang diagnostic pop

            int score = [[result valueForKey:@"score"] intValue];
            
            UIColor* __nullable (^scoreColor)(void) =
            ^{
                switch (score)
                {
                    case 0:
                    case 1: return UIColor.redColor;
                    case 2:
                    case 3: return UIColor.yellowColor;
                    case 4: return UIColor.greenColor;
                }
                
                return (UIColor*)nil;
            };
            //*
            textField.textColor = scoreColor();
            /*/
            textField.layer.shadowRadius = 1;
            textField.layer.shadowColor = scoreColor().CGColor;
            textField.layer.shadowOpacity = !answerIsEmpty ? 1 : 0;
            textField.layer.shadowPath = CGPathCreateWithRect
                (CGRectMake(width, textField.frame.size.height + 5,
                            textField.frame.size.width - 2 * width, 2), nil);
            //*/
            indicator.text = (answerIsEmpty ? nil :
                              (minimumPasswordStrength < score) ? @"👍" : @"👎");
        }
    }
    @catch(...) { }
}

@end
