source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

install! 'cocoapods', :disable_input_output_paths => true

target 'VLTDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for VLTDemo
  pod 'VLTMaps_HM'
  pod 'VLTSearch'
  #pod 'SwiftLint'
  
  target 'VLTDemoTests' do
    inherit! :search_paths
    # Pods for testing
    
  end

  target 'VLTDemoUITests' do
    # Pods for testing
    
  end

end

# Sync deployment targets to 13
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13'
    end
  end
end

