source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
platform :ios, '10.0'

plugin 'cocoapods-keys', {
    :project => "CelScore",
    :target => "CelScore",
    :keys => ["kAPIKey", "kCognitoIdentityPoolId"]
}

def shared_pods
    pod 'ReactiveCocoa', '6.0'
    pod 'ReactiveSwift', '~> 2.0'
    pod 'RealmSwift', '~> 2.10'
    pod 'Texture', '~> 2.5'
    pod 'AWSCognito', '2.6'
    pod 'AWSAPIGateway', '2.6'
    pod 'AWSPinpoint', '2.6'
end

target 'CelScore' do
    shared_pods
    pod 'Material', '~> 2.10'
    pod 'SwiftyTimer', '~> 2.0.0'
    pod 'SwiftyJSON', '3.1.4'
    pod 'ObjectMapper', '2.2'
    pod 'ObjectMapper+Realm', :git => 'https://github.com/jakenberg/ObjectMapper-Realm'
    pod 'R.swift', '~> 3.3'
    pod 'FBSDKLoginKit', '~> 4.24'
    pod 'FBSDKCoreKit', '~> 4.24'
    pod 'Fabric', '~> 1.6.11'
    pod 'Crashlytics', '~> 3.8'
    pod 'TwitterKit', '~> 3.1'
    pod 'TwitterCore', '~> 3.0'
    pod 'RateLimit', '~> 2.1'
    pod 'YLProgressBar', '~> 3.10'
    pod 'HMSegmentedControl', '~> 1.5.4'
    pod 'BEMCheckBox', '~> 1.4'
    pod 'SVProgressHUD', '~> 2.1'
    pod 'RevealingSplashView', '~> 0.4'
    pod 'PMAlertController', '~> 2.1'
    pod 'TTGSnackbar', '~> 1.5'
    pod 'Dwifft', '~> 0.6'
end

target 'CelScoreTests' do
    shared_pods
end

target 'The Courthouse' do
    
end



