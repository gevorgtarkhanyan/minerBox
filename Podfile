platform :ios, '9.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'MinerBox' do
  use_frameworks!

  pod 'Alamofire'
  pod 'Firebase/Core'
  pod 'RealmSwift'
  pod 'Charts'
  pod 'TOPasscodeViewController'
  pod 'QRCodeReader.swift'
  pod 'Localize-Swift'
  pod 'SDWebImage'
  pod 'libxlsxwriter'
  pod "TinyConstraints"

  # Crashlytics
  pod 'Firebase/Crashlytics'

  # Performance
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/DynamicLinks'

    target 'MinerBox Widget' do
      inherit! :search_paths
      pod 'Localize-Swift'
      pod 'Alamofire'
    end

    target 'FVCoinWidget' do
      inherit! :search_paths
      pod 'Localize-Swift'
      pod 'Alamofire'
    end

    target 'Service' do
      inherit! :search_paths
      pod 'Localize-Swift'
    end

    target 'Content' do
      inherit! :search_paths
      pod 'Localize-Swift'
    end

    target 'KitWidgetsExtension' do
      inherit! :search_paths
      pod 'Localize-Swift'
    end

    target 'KitWidgetsIntent' do
      inherit! :search_paths
      pod 'Localize-Swift'
    end
end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
#    end
#  end
#end
