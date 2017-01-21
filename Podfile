source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
platform :ios, '9.0'

plugin 'cocoapods-keys', {
    :project => "CelScore",
    :target => "CelScore",
    :keys => ["kAPIKey", "kCognitoIdentityPoolId"]
}

def shared_pods
    pod 'ReactiveCocoa', '~> 5.0.0-alpha.1'
    pod 'Result', '~> 3.1.0'
    pod 'Realm', '~> 2.3'
    pod 'RealmSwift', '~> 2.3'
    pod 'AsyncDisplayKit', '~> 1.9.90'
    pod 'AWSCognito', '~> 2.4.9'
    pod 'AWSAPIGateway', '~> 2.4.9'
    pod 'BEMCheckBox', '~> 1.4'
end

target 'CelScore' do
    shared_pods
    pod 'Material', '~> 2.4.10'
    pod 'SwiftyTimer', '~> 2.0.0'
    pod 'SwiftyJSON', '~> 3.1'
    pod 'SDWebImage', '~>3.8.1'
    pod 'R.swift', '~> 3.2'
    pod 'WebASDKImageManager', '~> 1.1'
    pod 'FBSDKLoginKit', '~> 4.18'
    pod 'FBSDKCoreKit', '~> 4.18'
    pod 'Fabric', '~> 1.6.7'
    pod 'Crashlytics', '~> 3.8'
    pod 'TwitterKit', '~> 2.7'
    pod 'TwitterCore', '~> 2.7'
    pod 'RateLimit', '~> 2.1'
    pod 'Timepiece', '~> 1.0'
    pod 'YLProgressBar', '~> 3.10'
    pod 'HMSegmentedControl', '~> 1.5.3'
    pod 'SVProgressHUD', '~> 2.1'
    pod 'RevealingSplashView', '~> 0.1'
    pod 'PMAlertController', '~> 2.0'
    pod 'Dwifft', '~> 0.5'
end

target 'CelScoreTests' do
    shared_pods
end

target 'The Courthouse' do
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end



