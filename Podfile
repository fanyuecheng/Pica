# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Pica' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pica

    pod 'YTKNetwork', '~> 3.0.6'
    pod 'YYModel', '~> 1.0.4' 
    pod 'SDWebImage', '~> 5.15.5'
    pod 'QMUIKit', '~> 4.6.3'  
    pod 'MJRefresh', '~> 3.7.5'
    pod 'JXPagingView/Pager', '~> 2.1.2'
    pod 'SocketRocket', '~> 0.6.0'
    pod 'GYDataCenter'
    pod 'FMDB', '~> 2.6.1'
    pod 'UMCommon', '~> 7.3.8'
    pod 'UMDevice', '~> 2.2.1'
    pod 'UMAPM', '~> 1.7.0' 
    pod 'SDWebImageVideoCoder', '~> 0.2.0' 
    pod 'SSZipArchive', '~> 2.4.3'
end

post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
       if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 11.0
         config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
       end
     end
   end
end