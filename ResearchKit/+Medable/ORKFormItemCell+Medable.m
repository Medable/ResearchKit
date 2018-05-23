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
        if (![answer isKindOfClass:NSString.class]) return;
        
        // in code below, use KVC (valueForKeyPath:), and
        // performSelector:withObject:, either of which could
        // trigger exception if underyling methods not available,
        // in order to bypass compiler/linker restrictions and
        // avoid adding explicit dependencies to this module (RK)
        
        Class DBZxcvbn = NSClassFromString(@"DBZxcvbn");
        NSString* answerFormatKeyPath = @"answerFormat.";

        NSInteger minimumPasswordStrength = // valueForKeyPath: could trigger exception
        [[self.formItem valueForKeyPath:@"answerFormat.minimumPasswordStrength"] integerValue];
        
        if (DBZxcvbn && minimumPasswordStrength && // valueForKeyPath: could trigger exception
            [[self.formItem valueForKeyPath::@"answerFormat.isSecureTextEntry"] boolValue])
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
            // theoretically this could trigger exception, but that
            // would mean `DBZxcvbn` API has changed, we already checked
            // for it's existence above
            id result = (!answerIsEmpty ?
                         [[DBZxcvbn new] performSelector:
                          NSSelectorFromString(@"passwordStrength:")
                                              withObject:answer] : nil);
            #pragma clang diagnostic pop

            NSInteger score = [[result valueForKey:@"score"] integerValue];
            
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
            
            textField.textColor = scoreColor();
            indicator.text = (answerIsEmpty ? nil :
                              (minimumPasswordStrength < score) ? @"👍" : @"👎");
        }
    }
    @catch(...) { } // anticipated exceptions are due to KVC/performSelector failure,
    // which means this functionality cannot be supported, so simply silently move on
}

@end
