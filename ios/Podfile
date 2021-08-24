platform :ios, '11.0'
source 'https://cdn.cocoapods.org/'
inhibit_all_warnings!

def main_pods
  #Layout
  pod 'SnapKit'
  
  #Tool
  pod 'SwiftLint'
  
  #Networking
  pod 'Magpie/HIPAPI', '~> 2.0.5'
  
  #Persistance
  pod 'KeychainAccess'
  
  #Date
  pod 'SwiftDate'
  
  #UI
  pod 'SVProgressHUD'
  pod 'lottie-ios'
  pod 'NotificationBannerSwift'
  pod 'BetterSegmentedControl', '~> 1.3'
  pod 'Charts'

  pod 'Macaroon/URLImage', :git => 'https://github.com/Hipo/macaroon.git', :tag => '2.12.0'
  pod 'Macaroon/MediaPicker', :git => 'https://github.com/Hipo/macaroon.git', :tag => '2.12.0'
  pod 'Macaroon/Banner', :git => 'https://github.com/Hipo/macaroon.git', :tag => '2.12.0'
  pod 'Macaroon/BottomSheet', :git => 'https://github.com/Hipo/macaroon.git', :tag => '2.12.0'
  pod 'Macaroon/BottomOverlay', :git => 'https://github.com/Hipo/macaroon.git', :tag => '2.12.0'
  pod 'Macaroon/Core', :git => 'https://github.com/Hipo/macaroon.git', :tag => '2.12.0'
  
  #Analytics
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'

  #Dependency
  pod 'WalletConnectSwift'
end

target 'algorand' do

  use_frameworks!
  
  main_pods
end

target 'algorand-prod' do

  use_frameworks!
  
  main_pods
end

target 'algorand-staging' do
  
  use_frameworks!
  
  main_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end
