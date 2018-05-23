//
//  MDRPasswordStrength.h
//  ResearchKit
//
//  Created by J.Rodden on 5/23/18.
//  Copyright © 2018 Medable Inc. All rights reserved.
//

typedef NS_ENUM(NSInteger, MDRPasswordStrength)
{
    MDRPasswordStrengthWeak = -1,
    MDRPasswordStrengthNormal = 0,
    MDRPasswordStrengthStrong = 1,
};

typedef void (^MDRPasswordStrengthBlock)(NSString *password,
                                         BOOL *passwordIsAcceptable,
                                         MDRPasswordStrength *strength);
