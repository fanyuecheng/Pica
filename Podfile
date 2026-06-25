# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

target 'Pica' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pica

    pod 'YTKNetwork', '~> 3.0.6'
    pod 'YYModel', '~> 1.0.4' 
    pod 'SDWebImage', '~> 5.21.7'
    pod 'QMUIKit', :git => 'https://github.com/CloudlessMoon/QMUI_iOS.git', :branch => 'master'  
    pod 'MJRefresh', '~> 3.7.5'
    pod 'JXPagingView/Pager', '~> 2.1.2'
    pod 'SocketRocket', '~> 0.7.1'
    pod 'GYDataCenter'
    pod 'FMDB', '~> 2.6.1'
    pod 'UMCommon', '~> 7.5.11'
    pod 'UMDevice', '~> 3.6.0'
    pod 'UMAPM', '~> 2.0.7' 
    pod 'SDWebImageVideoCoder', '~> 0.2.0' 
    pod 'SSZipArchive', '~> 2.6.0'
end

post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 16.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
       end
     end
   end
end