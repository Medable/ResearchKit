Pod::Spec.new do |s|
  s.name         = 'ResearchKit'

# Medable - for now, we're using a forked version of ResearchKit
  #s.version      = '1.4.1'
  s.version      = '1.4.1.1'

  s.summary      = 'ResearchKit is an open source software framework that makes it easy to create apps for medical research or for other research projects.'
  s.homepage     = 'https://www.github.com/ResearchKit/ResearchKit'
  s.documentation_url = 'http://researchkit.github.io/docs/'
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { 'researchkit.org' => 'http://researchkit.org' }

# Medable - for now, we're using a forked version of ResearchKit
  #s.source       = { :git => 'https://github.com/ResearchKit/ResearchKit.git', :tag => s.version.to_s }
  s.source       = { :git => 'https://github.com/Medable/ResearchKit.git', :branch => 'Medable_1.4.1', :tag => s.version.to_s }

# Medable - executing ruby doesn't work in forked RK repo??
  #s.public_header_files = `./scripts/find_headers.rb --public --private`.split("\n")
  s.public_header_files = 'ResearchKit/Common/ORKStepNavigationRule.h', 'ResearchKit/Common/ORKNavigableOrderedTask.h', 'ResearchKit/Charts/ORKDiscreteGraphChartView.h', 'ResearchKit/Common/ORKStep.h', 'ResearchKit/Common/ORKAnswerFormat.h', 'ResearchKit/ActiveTasks/ORKRecorder.h', 'ResearchKit/ActiveTasks/ORKTimedWalkStep.h', 'ResearchKit/Common/ORKFormStepViewController.h', 'ResearchKit/Common/ORKResult.h', 'ResearchKit/Common/ORKWaitStep.h', 'ResearchKit/Common/ORKStepViewController.h', 'ResearchKit/ActiveTasks/ORKActiveStepViewController.h', 'ResearchKit/Common/ORKFormStep.h', 'ResearchKit/Onboarding/ORKRegistrationStep.h', 'ResearchKit/Common/ORKWaitStepViewController.h', 'ResearchKit/Common/ORKDefines.h', 'ResearchKit/Common/ORKInstructionStep.h', 'ResearchKit/Onboarding/ORKVerificationStep.h', 'ResearchKit/Consent/ORKConsentSection.h', 'ResearchKit/Common/ORKPasscodeViewController.h', 'ResearchKit/Charts/ORKLineGraphChartView.h', 'ResearchKit/ResearchKit.h', 'ResearchKit/Common/ORKTaskViewController.h', 'ResearchKit/ActiveTasks/ORKActiveStep.h', 'ResearchKit/Charts/ORKGraphChartView.h', 'ResearchKit/Consent/ORKVisualConsentStep.h', 'ResearchKit/Common/ORKPasscodeStep.h', 'ResearchKit/Common/ORKKeychainWrapper.h', 'ResearchKit/Consent/ORKConsentSharingStep.h', 'ResearchKit/Common/ORKQuestionStep.h', 'ResearchKit/Common/ORKImageCaptureStep.h', 'ResearchKit/Common/ORKHealthAnswerFormat.h', 'ResearchKit/Charts/ORKPieChartView.h', 'ResearchKit/Common/ORKOrderedTask.h', 'ResearchKit/Onboarding/ORKLoginStepViewController.h', 'ResearchKit/Common/ORKResultPredicate.h', 'ResearchKit/Onboarding/ORKVerificationStepViewController.h', 'ResearchKit/Consent/ORKConsentReviewStep.h', 'ResearchKit/Common/ORKTask.h', 'ResearchKit/Consent/ORKConsentSignature.h', 'ResearchKit/Charts/ORKRangedPoint.h', 'ResearchKit/Onboarding/ORKLoginStep.h', 'ResearchKit/Consent/ORKConsentDocument.h', 'ResearchKit/Common/ORKImageCaptureStepViewController.h', 'ResearchKit/Common/ORKAnswerFormat_Private.h', 'ResearchKit/ActiveTasks/ORKReactionTimeStep.h', 'ResearchKit/Common/ORKCustomStepView.h', 'ResearchKit/ActiveTasks/ORKHolePegTestRemoveStep.h', 'ResearchKit/ActiveTasks/ORKDataLogger.h', 'ResearchKit/ActiveTasks/ORKToneAudiometryStepViewController.h', 'ResearchKit/Common/ORKInstructionStepViewController.h', 'ResearchKit/Common/ORKStepNavigationRule_Private.h', 'ResearchKit/ActiveTasks/ORKCountdownStep.h', 'ResearchKit/ActiveTasks/ORKToneAudiometryPracticeStepViewController.h', 'ResearchKit/ResearchKit_Private.h', 'ResearchKit/ActiveTasks/ORKHolePegTestPlaceStep.h', 'ResearchKit/Common/ORKQuestionStepViewController_Private.h', 'ResearchKit/Common/ORKOrderedTask_Private.h', 'ResearchKit/ActiveTasks/ORKTimedWalkStepViewController.h', 'ResearchKit/Common/ORKDefines_Private.h', 'ResearchKit/Consent/ORKConsentSharingStepViewController.h', 'ResearchKit/Common/ORKQuestionStepViewController.h', 'ResearchKit/Consent/ORKVisualConsentStepViewController.h', 'ResearchKit/Common/ORKCompletionStepViewController.h', 'ResearchKit/Common/ORKPasscodeStepViewController.h', 'ResearchKit/ActiveTasks/ORKWalkingTaskStep.h', 'ResearchKit/ActiveTasks/ORKToneAudiometryPracticeStep.h', 'ResearchKit/ActiveTasks/ORKSpatialSpanMemoryStep.h', 'ResearchKit/ActiveTasks/ORKAudioStepViewController.h', 'ResearchKit/ActiveTasks/ORKRecorder_Private.h', 'ResearchKit/ActiveTasks/ORKTowerOfHanoiStep.h', 'ResearchKit/ActiveTasks/ORKHolePegTestRemoveStepViewController.h', 'ResearchKit/ActiveTasks/ORKPSATStepViewController.h', 'ResearchKit/Common/ORKCompletionStep.h', 'ResearchKit/ActiveTasks/ORKCountdownStepViewController.h', 'ResearchKit/Consent/ORKConsentReviewStepViewController.h', 'ResearchKit/ActiveTasks/ORKFitnessStepViewController.h', 'ResearchKit/ActiveTasks/ORKFitnessStep.h', 'ResearchKit/Common/ORKTaskViewController_Private.h', 'ResearchKit/ActiveTasks/ORKTappingIntervalStepViewController.h', 'ResearchKit/ActiveTasks/ORKWalkingTaskStepViewController.h', 'ResearchKit/ActiveTasks/ORKPSATStep.h', 'ResearchKit/Common/ORKResult_Private.h', 'ResearchKit/Common/ORKErrors.h', 'ResearchKit/ActiveTasks/ORKToneAudiometryStep.h', 'ResearchKit/ActiveTasks/ORKHolePegTestPlaceStepViewController.h', 'ResearchKit/ActiveTasks/ORKSpatialSpanMemoryStepViewController.h', 'ResearchKit/ActiveTasks/ORKTappingIntervalStep.h', 'ResearchKit/ActiveTasks/ORKAudioStep.h'

  s.source_files = 'ResearchKit/**/*.{h,m,swift}'
  s.resources    = 'ResearchKit/**/*.{fsh,vsh}', 'ResearchKit/Animations/**/*.m4v', 'ResearchKit/Artwork.xcassets', 'ResearchKit/Localized/*.lproj'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
end
