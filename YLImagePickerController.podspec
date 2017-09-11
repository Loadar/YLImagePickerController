Pod::Spec.new do |s|
  s.name             = 'YLImagePickerController'

  s.version          = '0.0.5'
  s.summary          = '选择相册和拍照 支持多种裁剪'

  s.description      = <<-DESC
                        自定义相册和自定义拍照 支持多种裁剪
                       DESC
  s.homepage         = 'https://github.com/February12/YLImagePickerController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yl' => '845369698@qq.com' }
                                               
  s.source           = { 
                        :git => 'https://github.com/February12/YLImagePickerController.git', 
                        :tag => s.version.to_s 
                       }

  s.ios.deployment_target = '8.0'
  s.platform     = :ios, '8.0'
  s.source_files = ["Sources/**/*.swift","Sources/**/*.xib"]
  s.resource_bundles = {
    'YLImagePickerController' => ['Sources/**/*.png']
  }

  s.requires_arc = true

  s.dependency 'TOCropViewController', '~> 2.0.12'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

end