source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
platform :ios, '9.0'

plugin 'cocoapods-keys', {
    :project => "CelScore",
    :target => "CelScore",
    :keys => ["kAPIKey", "kCognitoIdentityPoolId"]
}

def shared_pods
    pod 'ReactiveCocoa', '4.2.2'
    pod 'Realm', '~> 1.1.0'
    pod 'RealmSwift', '~> 1.1.0'
    pod 'AsyncDisplayKit', '~> 1.9.80'
    pod 'AWSCognito', '~> 2.4.9'
    pod 'AWSAPIGateway', '~> 2.4.9'
    pod 'BEMCheckBox', '~> 1.2'
end

target 'CelScore' do
    shared_pods
    pod 'SwiftyTimer', '~> 2.0.0'
    pod 'SwiftyJSON', '~> 2.4'
    pod 'SDWebImage', '~>3.8.1'
    pod 'Material', :git => 'https://github.com/CosmicMind/Material.git', :branch => 'development'
    pod 'R.swift', '~> 3.0'
    pod 'WebASDKImageManager', '~> 1.1'
    pod 'FBSDKLoginKit', '~> 4.14'
    pod 'FBSDKCoreKit', '~> 4.14'
    pod 'Fabric', '~> 1.6.7'
    pod 'Crashlytics', '~> 3.7.2'
    pod 'TwitterKit', '~> 2.4'
    pod 'TwitterCore', '~> 2.4'
    pod 'RateLimit', '~> 1.2'
    pod 'Timepiece', :git => 'https://github.com/skofgar/Timepiece.git', :branch => 'swift3'
    pod 'YLProgressBar', '~> 3.8.1'
    pod 'SMSegmentView', '~> 1.1'
    pod 'HMSegmentedControl', '~> 1.5.2'
    pod 'SVProgressHUD', '~> 2.0.3'
    pod 'RevealingSplashView', '~> 0.0'
    pod 'PMAlertController', '~> 2.0'
    pod 'Dwifft', '~> 0.4'
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



