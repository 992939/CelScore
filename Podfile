use_frameworks!
platform :ios, '9.0'

plugin 'cocoapods-keys', {
    :project => "CelScore",
    :target => "CelScore",
    :keys => ["kAPIKey", "kCognitoIdentityPoolId"]
}

def shared_pods
    pod 'ReactiveCocoa', '~> 4.1'
    pod 'RealmSwift', '~> 1.0'
    pod 'AIRTimer', '~> 1.0.2'
    pod 'SwiftyJSON', '~> 2.3.2'
    pod 'PINCache', '~> 2.2.2'
end

target 'CelScore' do
    shared_pods
    pod 'Material', '~> 1.41.8'
    pod 'R.swift', '~> 2.3'
    pod 'AsyncDisplayKit', '~> 1.9.7.2'
    pod 'WebASDKImageManager', '~> 1.0'
    pod 'SDWebImage', '~>3.8.1'
    pod 'AWSCognito', '2.4.3'
    pod 'AWSAPIGateway', '~> 2.4.3'
    pod 'FBSDKLoginKit', '~> 4.12'
    pod 'FBSDKCoreKit', '~> 4.12'
    pod 'Fabric', '~> 1.6.7'
    pod 'Crashlytics', '~> 3.7.0'
    pod 'TwitterKit', '~> 2.2.0'
    pod 'TwitterCore', '~> 2.2.0'
    pod 'RateLimit', '~> 1.2'
    pod 'Timepiece', '~> 0.4.2'
    pod 'YLProgressBar', '~> 3.8.1'
    pod 'SMSegmentView', '~> 1.1'
    pod 'BEMCheckBox', '~> 1.2'
    pod 'HMSegmentedControl', '~> 1.5.2'
    pod 'SVProgressHUD', '~> 2.0.3'
    pod 'Dwifft', '~> 0.3.1'
    pod 'RevealingSplashView', '~> 0.0'
    pod 'SIAlertView', '~> 1.3'
end

target 'CelScoreTests' do
    shared_pods
end

target 'TheObservatory' do
    shared_pods
end



